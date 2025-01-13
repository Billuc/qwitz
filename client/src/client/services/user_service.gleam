import client/utils
import lustre/effect
import shared/user

pub fn login(
  pseudo: String,
  password: String,
  cb: fn(user.User) -> a,
) -> effect.Effect(a) {
  utils.rpc_effect(user.login(), user.LoginData(pseudo:, password:), cb)
}
