import gleam/list
import gleam/result
import gleamrpc
import server/context
import server/db_utils
import server/question/sql
import shared/question
import youid/uuid

pub fn register(
  server: gleamrpc.ProcedureServerInstance(_, _, context.Context, _),
) -> gleamrpc.ProcedureServerInstance(_, _, context.Context, _) {
  server
  |> gleamrpc.with_implementation(question.get_question(), get)
  |> gleamrpc.with_implementation(question.get_questions(), get_all)
  |> gleamrpc.with_implementation(question.create_question(), create)
  |> gleamrpc.with_implementation(question.update_question(), update)
  |> gleamrpc.with_implementation(question.delete_question(), delete)
}

fn get(
  params: uuid.Uuid,
  context: context.Context,
) -> Result(question.Question, gleamrpc.ProcedureError) {
  {
    use db <- db_utils.transaction(context)
    sql.get_question(db, params)
  }
  |> result.then(db_utils.get_one)
  |> result.map(fn(v: sql.GetQuestionRow) {
    question.Question(id: v.id, qwiz_id: v.qwiz_id, question: v.question)
  })
}

fn get_all(
  _params: Nil,
  context: context.Context,
) -> Result(List(question.Question), gleamrpc.ProcedureError) {
  {
    use db <- db_utils.transaction(context)
    sql.get_all_questions(db)
  }
  |> result.map(db_utils.get_all)
  |> result.map(fn(v: List(sql.GetAllQuestionsRow)) {
    use question_row <- list.map(v)
    question.Question(
      id: question_row.id,
      qwiz_id: question_row.qwiz_id,
      question: question_row.question,
    )
  })
}

fn create(
  params: question.CreateQuestion,
  context: context.Context,
) -> Result(question.Question, gleamrpc.ProcedureError) {
  let id = uuid.v4()

  {
    use db <- db_utils.transaction(context)
    sql.create_question(db, id, params.qwiz_id, params.question)
    |> result.then(fn(_) { sql.get_question(db, id) })
  }
  |> result.then(db_utils.get_one)
  |> result.map(fn(v: sql.GetQuestionRow) {
    question.Question(id: v.id, qwiz_id: v.qwiz_id, question: v.question)
  })
}

fn update(
  params: question.Question,
  context: context.Context,
) -> Result(question.Question, gleamrpc.ProcedureError) {
  {
    use db <- db_utils.transaction(context)
    sql.update_question(db, params.question, params.id)
    |> result.then(fn(_) { sql.get_question(db, params.id) })
  }
  |> result.then(db_utils.get_one)
  |> result.map(fn(v: sql.GetQuestionRow) {
    question.Question(id: v.id, qwiz_id: v.qwiz_id, question: v.question)
  })
}

fn delete(
  params: uuid.Uuid,
  context: context.Context,
) -> Result(Nil, gleamrpc.ProcedureError) {
  {
    use db <- db_utils.transaction(context)
    sql.delete_question(db, params)
  }
  |> result.replace(Nil)
}
