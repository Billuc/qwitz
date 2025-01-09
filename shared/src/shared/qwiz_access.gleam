import shared

pub type QwizAccess {
  QwizAccess(
    id: shared.Uuid,
    user_id: shared.Uuid,
    qwiz_id: shared.Uuid,
    access: AccessType,
  )
}

pub type AccessType {
  ReadWrite
  Read
  None
}
