import client/utils
import lustre/effect
import shared
import shared/qwiz

pub fn get_qwizes(cb: fn(List(qwiz.Qwiz)) -> a) -> effect.Effect(a) {
  utils.rpc_effect(qwiz.get_qwizes(), Nil, cb)
}

pub fn get_qwiz(
  id: shared.Uuid,
  cb: fn(qwiz.QwizWithQuestions) -> b,
) -> effect.Effect(b) {
  utils.rpc_effect(qwiz.get_qwiz(), id, cb)
}

pub fn create_qwiz(
  name: String,
  owner: shared.Uuid,
  cb: fn(qwiz.QwizWithQuestions) -> c,
) -> effect.Effect(c) {
  utils.rpc_effect(qwiz.create_qwiz(), qwiz.UpsertQwiz(name, owner), cb)
}

pub fn update_qwiz(
  qwiz: qwiz.Qwiz,
  cb: fn(qwiz.QwizWithQuestions) -> d,
) -> effect.Effect(d) {
  utils.rpc_effect(qwiz.update_qwiz(), qwiz, cb)
}

pub fn delete_qwiz(id: shared.Uuid, cb: fn(Nil) -> d) -> effect.Effect(d) {
  utils.rpc_effect(qwiz.delete_qwiz(), id, cb)
}
