- User
  - nick_name:string
  - avatar:image
  - admin:boolean
  - has_many :questions
  - has_many :answers

  <br>

- Question
  - body:text
  - user:references
  - solved:boolean
  - belongs_to :user

  <br>

- Answer
  - body:text
  - user:references
  - question:references
  - belongs_to :user
  - belongs_to :question

