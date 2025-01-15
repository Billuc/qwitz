import client/utils
import shared
import shared/qwiz

pub fn get_qwizes(cb) {
  utils.exec_procedure(qwiz.get_qwizes(), Nil, cb)
}

pub fn get_qwiz(id: shared.Uuid, cb) {
  utils.exec_procedure(qwiz.get_qwiz(), id, cb)
}

pub fn create_qwiz(data: qwiz.CreateQwiz, cb) {
  utils.exec_procedure(qwiz.create_qwiz(), data, cb)
}

pub fn update_qwiz(qwiz: qwiz.Qwiz, cb) {
  utils.exec_procedure(qwiz.update_qwiz(), qwiz, cb)
}

pub fn delete_qwiz(id: shared.Uuid, cb) {
  utils.exec_procedure(qwiz.delete_qwiz(), id, cb)
}
