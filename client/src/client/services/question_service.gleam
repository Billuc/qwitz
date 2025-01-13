import client/utils
import lustre/effect
import shared
import shared/question

pub fn create_question(
  qwiz_id: shared.Uuid,
  question: String,
  cb,
) -> effect.Effect(c) {
  utils.rpc_effect(
    question.create_question(),
    question.CreateQuestion(qwiz_id:, question:),
    cb,
  )
}

pub fn delete_question(id: shared.Uuid, cb: fn(Nil) -> d) -> effect.Effect(d) {
  utils.rpc_effect(question.delete_question(), id, cb)
}
