require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  ### The `.create` Method

# This method creates a student with two attributes, name and grade, and saves it into the students table.

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
  end

  # saves an instance of the Student class to the database and then sets the given students `id` attribute
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end 

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

#   This class method takes an argument of an array. When we call this method we will pass it the array that is the row returned from the database by the execution of a SQL query. We can anticipate that this array will contain three elements in this order: the id, name and grade of a student. 

# The `.new_from_db` method uses these three array elements to create a new `Student` object with these attributes. 
  def self.new_from_db(row)
   student = self.new(row[1], row[2], row[0])
   student
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * 
    FROM students
    WHERE name = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  # This method updates the database row mapped to the given `Student` instance. 

  def update
    sql = <<-SQL
    UPDATE students
    SET name = ?,
    grade = ?
    WHERE
    id = ?
    SQL

      DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
  

  


end
