import shared/user

pub type Msg {
  Login(username: String, password: String)
  SetUser(user: user.User)
}
