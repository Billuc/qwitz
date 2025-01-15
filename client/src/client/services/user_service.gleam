import client/utils
import shared/user

pub fn login(pseudo: String, password: String, cb) {
  utils.exec_procedure(user.login(), user.LoginData(pseudo:, password:), cb)
}
