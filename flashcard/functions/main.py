# Welcome to Cloud Functions for Firebase for Python!
# Deploy with `firebase deploy`

import statistics
from firebase_functions import https_fn, firestore_fn
from firebase_admin import firestore, initialize_app
from datetime import datetime, timedelta
import os.path
import stripe


from firebase_functions.firestore_fn import Event, Change, DocumentSnapshot
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
import base64
from email.message import EmailMessage
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import pytz

# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/gmail.readonly",
          "https://www.googleapis.com/auth/gmail.send",
          "https://www.googleapis.com/auth/gmail.labels",
          "https://www.googleapis.com/auth/gmail.compose"]

# initialize_app()
app = initialize_app()


@https_fn.on_request()
def sendEmail(req: https_fn.Request) -> https_fn.Response:
    """Shows basic usage of the Gmail API.
    Lists the user's Gmail labels.
    """

    "Load user credentials from the environment"
    yesterday = datetime.today() - timedelta(days=1)
    yesterday_parsed = yesterday.strftime("%Y-%m-%d")
    local_timezone = pytz.timezone('Europe/London')

    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists("token.json"):
        creds = Credentials.from_authorized_user_file("token.json", SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                "credentials.json", SCOPES
            )
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open("token.json", "w") as token:
            token.write(creds.to_json())

    db = firestore.Client.from_service_account_json('firebase-private.json')

    try:
        # Call the Gmail API
        sender = "medicrecall@gmail.com"
        subject = "MedicRecall Revision Reminder"
        receiver = ""
        service = build("gmail", "v1", credentials=creds)

        users_ref = db.collection("users")
        docs = users_ref.stream()

        for doc in docs:

            document_data = doc.to_dict()  # Convert the document snapshot to a Python dictionary
            email = document_data.get(
                'email')  # Get the value of the 'email' field from the document
            checkNotify = document_data.get(
                'notify')  # Get the value of the 'notify' field from document to see if the user wants to be notified
            if email:
                receiver = email
            else:
                print(f"Document ID: {doc.id}, Email field not found")

            events_ref = doc.reference.collection("events")
            if events_ref.get():

                events_docs = events_ref.stream()

                for events_doc in events_docs:

                    event_data = events_doc.to_dict()
                    complete_date = event_data.get('date')
                    local_timestamp = complete_date.astimezone(local_timezone)
                    events_day_list = event_data.get('events')

                    # Format the datetime object into the desired format
                    formatted_date = local_timestamp.strftime("%Y-%m-%d")

                    if formatted_date == yesterday_parsed:

                        events_string = ', '.join(events_day_list)
                        body = "This is your reminder to revise the following topics that were due yesterday: \n{}".format(
                            events_string)

                        if checkNotify == True:
                            gmail_send_message(service, sender, receiver, subject, body)
                        else:
                            body = None

                    else:
                        body = None

            else:
                print(f"Document ID: {doc.id}, Events field not found")

        return https_fn.Response(f"Success", status=200)

    except HttpError as error:
        print(f"An error occurred: {error}")


def gmail_create_draft(service, sender, receiver, subject, body):
    """Create and insert a draft email.
     Print the returned draft's message and id.
     Returns: Draft object, including draft id and message meta data."""

    try:

        message = EmailMessage()

        message.set_content(body)

        message["To"] = receiver
        message["From"] = sender
        message["Subject"] = subject

        # encoded message
        encoded_message = base64.urlsafe_b64encode(message.as_bytes()).decode()

        create_message = {"message": {"raw": encoded_message}}

        draft = (
            service.users()
            .drafts()
            .create(userId="me", body=create_message)
            .execute()
        )

        print(f'Draft id: {draft["id"]}\nDraft message: {draft["message"]}')

    except HttpError as error:
        print(f"An error occurred: {error}")
        draft = None

    return draft


def gmail_send_message(service, sender, receiver, subject, body):
    """Create and send an email message
    Print the returned  message id
    Returns: Message object, including message id"""

    try:

        draft = gmail_create_draft(service, sender, receiver,
                                   subject, body)
        sent_draft = (
            service.users()
            .drafts()
            .send(userId="me", body={"id": draft['id']})
            .execute()
        )

        print(f'Draft sent successfully. Message id: {sent_draft["id"]}')

    except HttpError as error:
        print(f"An error occurred: {error}")
        sent_draft = None

    return sent_draft


@firestore_fn.on_document_written(document="users/{user}/examAnswers/{mock}")
def update_exam_score(event: Event[Change[DocumentSnapshot]]) -> None:
    db = firestore.Client()
    """Triggered when an exam answer is updated and updates the median score."""

    # Check if the doc has only just been created or deleted
    try:
        after = (event.data.after.get("score") if event.data.after is not None else None)
    except:
        after = None
    try:
        before = (event.data.before.get("score") if event.data.before is not None else None)
    except:
        before = None

    # Only proceed if the score was changed
    if before == after:
        return

    mock_id = event.params["mock"].replace("-answers", "")
    stats_ref = db.collection("mini-mock-stats").document(mock_id)

    # Fetch the current scores array from the document
    stats_doc = stats_ref.get()
    if stats_doc.exists:
        stats_data = stats_doc.to_dict()
        scores = stats_data.get("scores", [])  # Get scores array, default to empty list
    else:
        scores = []

    # Remove the old score if it exists
    if before in scores and before is not None:
        scores.remove(before)

    # Add the new score
    if after is not None:
        scores.append(after)

    # Calculate median if scores exist
    if len(scores) > 1:
        median_score = statistics.median(scores)
    else:
        median_score = after  # No scores present

    # Store the median in mini-mock-stats/{mock}.medianScore
    stats_ref.set({"scores": scores, "median": median_score}, merge=True)

    print(f"Updated median score for {mock_id}: {median_score}")

# STRIPE WEBHOOKS
STRIPE_WEBHOOK_SECRET = "PLACEHOLDER"  # Replace with your actual secret

@https_fn.on_request()
def stripe_webhook(req: https_fn.Request) -> https_fn.Response:
    payload = req.get_data()
    sig_header = req.headers.get("stripe-signature")

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, STRIPE_WEBHOOK_SECRET
        )
    except ValueError:
        return https_fn.Response("Invalid payload", status=400)
    except stripe.error.SignatureVerificationError:
        return https_fn.Response("Invalid signature", status=400)

    # Handle the event
    if event["type"] == "payment_intent.succeeded":
        payment_intent = event["data"]["object"]
        print(f"PaymentIntent was successful: {payment_intent['id']}")

    return https_fn.Response("Webhook received", status=200)