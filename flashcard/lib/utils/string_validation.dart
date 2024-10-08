class StringValidation {
  static String? validateName({String? name}) {
    if (name!.isEmpty) {
      return 'Name can\'t be empty';
    }

    return null;
  }

  static String? validateEmail({String? email}) {
    if (email!.isEmpty) {
      return 'This field is required';
    }
    if (!email.contains('@')) {
      return "A valid email address should contain '@'";
    }
    if (!RegExp(
      r"""
^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""",
    ).hasMatch(email)) {
      return "Please enter a valid email";
    }
    return null;
  }

  static String? validatePassword({String? password}) {
    if (password!.isEmpty) {
      return 'This field is required';
    }
    if (password.length < 8) {
      return 'Password should have atleast 8 characters';
    }
    if (!RegExp(r'[A-Z0-9a-z]*').hasMatch(password)) {
      return 'Enter a stronger password';
    }

    return null;
  }
}
