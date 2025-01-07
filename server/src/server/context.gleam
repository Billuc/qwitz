import gleam/http/request
import mist
import pog

pub type Context {
  Context(req: request.Request(mist.Connection), db: pog.Connection)
}
