# Welcome to Cloud Functions for Firebase for Python!
# Deploy with `firebase deploy`
from firebase_functions import https_fn, firestore_fn, scheduler_fn
from firebase_admin import initialize_app, firestore, credentials, auth
from datetime import datetime, timedelta
import os.path
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

initialize_app()


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
