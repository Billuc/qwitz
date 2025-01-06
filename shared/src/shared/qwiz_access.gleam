import youid/uuid

pub type QwizAccess {
  QwizAccess(
    id: uuid.Uuid,
    user_id: uuid.Uuid,
    qwiz_id: uuid.Uuid,
    access: AccessType,
  )
}

pub type AccessType {
  ReadWrite
  Read
  None
}
