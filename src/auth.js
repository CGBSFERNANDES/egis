let authenticated = false;

export default {
  authenticated() {
    return authenticated;
  },
  logIn() {
    authenticated = true;
  },
  logOut() {
    authenticated = false;
  }
};
