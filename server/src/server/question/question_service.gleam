import gleam/dict
import gleam/list
import gleam/option
import gleam/result
import gleamrpc
import server/context
import server/db_utils
import server/question/sql
import shared/answer
import shared/question
import youid/uuid

pub fn register(
  server: gleamrpc.ProcedureServerInstance(_, _, context.Context, _),
) -> gleamrpc.ProcedureServerInstance(_, _, context.Context, _) {
  server
  |> gleamrpc.with_implementation(question.get_questions(), get_all)
  |> gleamrpc.with_implementation(question.create_question(), create)
  |> gleamrpc.with_implementation(question.update_question(), update)
  |> gleamrpc.with_implementation(question.delete_question(), delete)
}

fn get_all(
  params: uuid.Uuid,
  context: context.Context,
) -> Result(List(question.QuestionWithAnswers), gleamrpc.ProcedureError) {
  {
    use db <- db_utils.transaction(context)
    sql.get_all_questions(db, params)
  }
  |> result.map(db_utils.get_all)
  |> result.map(fn(v: List(sql.GetAllQuestionsRow)) {
    v
    |> list.fold(dict.new(), fn(acc, curr) {
      acc
      |> dict.upsert(curr.question_id, upsert_question_with_answers(_, curr))
    })
    |> dict.values
  })
}

fn upsert_question_with_answers(
  old_value: option.Option(question.QuestionWithAnswers),
  row: sql.GetAllQuestionsRow,
) -> question.QuestionWithAnswers {
  case old_value {
    option.None -> row_to_question_with_answers(row)
    option.Some(q) ->
      question.QuestionWithAnswers(
        ..q,
        answers: add_answer_from_row(q.answers, row),
      )
  }
}

fn row_to_question_with_answers(
  v: sql.GetAllQuestionsRow,
) -> question.QuestionWithAnswers {
  question.QuestionWithAnswers(
    v.question_id,
    v.qwiz_id,
    v.question,
    add_answer_from_row([], v),
  )
}

fn add_answer_from_row(
  answers: List(answer.Answer),
  v: sql.GetAllQuestionsRow,
) -> List(answer.Answer) {
  case v.answer_id, v.answer, v.correct {
    option.Some(answer_id), option.Some(answer), option.Some(correct) -> [
      answer.Answer(answer_id, v.question_id, answer, correct),
      ..answers
    ]
    _, _, _ -> answers
  }
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
