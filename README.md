# Nested Forms Readme

## Overview

In this code-along lesson, we'll cover nested forms that can create multiple objects using Rails.

## Objectives

1. Create models for each class of objects
2. Structure data that a controller action will receive to handle multiple objects
3. Structure the HTML in `.erb` files that handle nesting
4. Create a view file that displays the objects back to the user
5. Create controller actions that serve up the form and process the data from the form

## Forms That Create Multiple Objects

In web apps, we use forms to create objects. When you fill out a form for a dinner reservation on Open Table, you're creating a reservation object. When you upload a photo to Instagram, you're creating an image object.

Those are examples of using forms to create a single object, but what if you wanted to use a form to create more than one object? This is where nested forms comes in.

Let's say we're in the registrar's office at a school and it's the start of the school year. We need to create each student and their course schedule. It would be tedious to go through the steps to first create the student and then go through the same steps again and again to create each of that student's courses. Wouldn't it be nice to create the student **and** their courses in one go?

## The Models

To create these two different classes of objects, we need to create two models, `Student` and `Course`.

### `Student` model

Our `Student` model, with `name` and `grade` attributes, will look something like this:

```ruby
class Student < ApplicationRecord
  attr_accessor :name, :grade

  def initialize(params = {})
    @name = params[:name]
    @grade = params[:grade]
  end
end
```

In Rails, we typically inherit from `ApplicationRecord` (which inherits from `ActiveRecord::Base`) to get database functionality. For this example, we're using `attr_accessor` to create getter and setter methods for `name` and `grade`, and we set the value of those attributes on initialization.

### `Course` model

Now let's set up the model for the courses each student is taking.

```ruby
class Course < ApplicationRecord
  attr_accessor :name, :topic

  def initialize(params = {})
    @name = params[:name]
    @topic = params[:topic]
  end
end
```

Here, exactly like with our `Student` model, we have `attr_accessor` for `name` and `topic`, and we set the value of those attributes on initialization.

## Creating the Form

The first thing we need is to create the form. In Rails, we'll use the `form_with` helper method in our view file `new.html.erb`.

Before we dive into the HTML, let's think about how we want to structure the data our controller action will receive. Typically, if we were just doing student information, we would expect the `params` hash to look something like this:

```ruby
params = {
  "name" => "Joe",
  "grade" => "9"
}
```

But how do we handle a student **and** a course? Both course and student have a `name` attribute. If keys in hashes have to be unique, we can't have `name` twice. We could call our keys `student_name` and `course_name`, but that really isn't best practice. And how would the hash look with two courses? `course_one_name` and `course_two_name`? Suddenly our keys are getting messy.

Instead, we need to think about restructuring our `params` hash to have nested hashes. We can have one hash for all of the student information:

```ruby
params = {
  "student" => {
    "name" => "Joe",
    "grade" => "9",
  }
}
```

Now we have a `student` key that stores a hash containing a given student's `name` and `grade`.

How would we create a hash like this in Ruby? Like so:

```ruby
my_hash = {}
my_hash["student"] = {}
my_hash["student"]["name"] = "Joe"
```

In Rails, we can use the `form_with` helper which provides a clean syntax for handling nested forms. It handles that first level of nesting automatically. Let's go ahead and build out the Rails form:

```erb
<%= form_with model: @student, url: students_path, local: true do |form| %>
  Student Name: <%= form.text_field :name %>
  Student Grade: <%= form.text_field :grade %>
  <%= form.submit %>
<% end %>
```

This Rails form will get submitted via a POST request to the `students_path` (which routes to the `create` action of the `StudentsController`). The `form_with` helper automatically sets up the proper form structure and CSRF protection. You'll notice how the form helper methods like `text_field` automatically create the proper `name` attributes as `student[name]` and `student[grade]`.

Now, let's think about how we want a course to fit in a student's `params` hash:

```ruby
params = {
  "student" => {
    "name" => "Joe",
    "grade" => "9",
    "course" => {
      "name" => "US History",
      "topic" => "History"
    }
  }
}
```

In this hash, both `student` and `course` can have the key `name` because they're in different namespaces.

Let's think about how we'd build this hash using Ruby:

```ruby
my_hash = {}
my_hash["student"] = {}
my_hash["student"]["name"] = "Joe"
my_hash["student"]["course"] = {}
my_hash["student"]["course"]["name"] = "US History"
my_hash["student"]["course"]["topic"] = "History"

my_hash
  => {"student"=>{"name"=>"Joe", "course"=>{"name"=>"US History", "topic"=>"History"}}}
```

Again, we can use Rails form helpers to set up our form. We can use `fields_for` to create nested form fields for the course, turning `my_hash["student"]["course"]["name"]` into organized form helper methods.

Let's go ahead and build out the corresponding Rails form:

```erb
<%= form_with model: @student, url: students_path, local: true do |form| %>
  Student Name: <%= form.text_field :name %>
  Student Grade: <%= form.text_field :grade %>
  <%= form.fields_for :course do |course_form| %>
    Course Name: <%= course_form.text_field :name %>
    Course Topic: <%= course_form.text_field :topic %>
  <% end %>
  <%= form.submit %>
<% end %>
```

In this form, the `fields_for :course` helper creates the nested structure we outlined above, automatically setting up the proper field names like `student[course][name]` and `student[course][topic]`. But this leaves us with a much bigger problem. How do we handle **two** (or more!) courses?

We need to once again restructure how we want to store data in the `params` hash. To allow for multiple courses, the `courses` key should store an array of nested hashes:

```ruby
params = {
  "student" => {
    "name" => "Vic",
    "grade" => "12",
    "courses" => [
      {
        "name" => "AP US History",
        "topic" => "History"
      },
      {
        "name" => "AP Human Geography",
        "topic" => "History"
      }
    ]
  }
}
```

This simple, nested pattern is easy to mimic no matter what type of object you're creating. It's much simpler than creating a new key for each course, e.g., `first_course`, `second_course`, `third_course`, etc.

The Rails form for this looks like this:

```erb
<%= form_with model: @student, url: students_path, local: true do |form| %>
  Student Name: <%= form.text_field :name %>
  Student Grade: <%= form.text_field :grade %>
  <%= form.fields_for :courses do |course_form| %>
    Course Name: <%= course_form.text_field :name %>
    Course Topic: <%= course_form.text_field :topic %>
  <% end %>
  <%= form.fields_for :courses do |course_form| %>
    Course Name: <%= course_form.text_field :name %>
    Course Topic: <%= course_form.text_field :topic %>
  <% end %>
  <%= form.submit %>
<% end %>
```

We removed the singular `:course` fields and replaced them with multiple `:courses` field sets that allow for the creation of TWO courses. The `fields_for :courses` helper automatically handles the array structure for us. This creates a key called `courses` inside of the `student` hash in `params`. The `courses` key will store an array of hashes, each containing course details.

Rails form helpers make this much easier than raw HTML. Instead of manually managing array indices like `student[courses][0][name]`, Rails automatically handles the indexing when you use `fields_for` with a plural association name like `:courses`.

## The Display View

We need a way to display the objects back to the user (in this case the registrar) once the student and their courses have been created. In Rails, we'll call this file `show.html.erb`.

```erb
<h1>Student</h1>

<div class="student">
  <h3>Name: <%= @student.name %></h3><br>
  <h4>Grade: <%= @student.grade %></h4>
</div><br>

<h1>Courses</h1>
<% @courses.each do |course| %>
  <div class="course">
    <p>Name: <%= course.name %></p><br>
    <p>Topic: <%= course.topic %></p><br>
  </div><br>
<% end %>
```

In this view, we use the instance variable `@student` and the reader methods `.name` and `.grade` to display the student's information.

We then iterate over `@courses` to display the name and topic of each course.

## The Controller

Now, we need controller actions to serve up the form and process the data from the form. In Rails, this would be a `StudentsController`:

In order to serve the form in the browser, we need a `new` action:

```ruby
class StudentsController < ApplicationController
  def new
    @student = Student.new
  end
end
```

And now we need a way to process the input from the user and to display the student and their courses. We process a form with a `create` action:

```ruby
def create
  @student = Student.new(student_params[:student])

  @courses = []
  student_params[:student][:courses].each do |course_details|
    @courses << Course.new(course_details)
  end

  render :show
end

private

def student_params
  params.permit(student: [:name, :grade, courses: [:name, :topic]])
end
```

In this controller action, we first create a new `Student` using the info stored in the permitted parameters, which contains the student's `name`, `grade`, and `courses`.

Then we iterate over the courses array, which contains a series of hashes that each store individual course information:

```ruby
[
  0 => {
    "name" => "AP US History",
    "topic" => "History"
  },
  1 => {
    "name" => "AP Human Geography",
    "topic" => "History"
  }
]
```

During the iterative process, we use the course values passed into the `.each` block to create instances of our `Course` class. We store the instantiated courses in the instance variable `@courses`, making the course information available within our view, `show.html.erb`.

Finally, the controller action renders the `show.html.erb` file, and we can see all of the newly-created student and course information in the browser.

Note the use of `student_params` - this is Rails' strong parameters feature that helps protect against mass assignment vulnerabilities by explicitly permitting only the parameters we expect.
