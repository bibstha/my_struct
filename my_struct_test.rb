require 'minitest/test'
require 'minitest/autorun'
require 'minitest/pride'

class MyStruct
  class << self
    attr_accessor :members

    def new(*args)
      if self == MyStruct
        build_struct_subclass(args)
      else
        super
      end
    end

    def build_struct_subclass(args)
      Class.new(MyStruct) do
        self.members = args

        args.each do |arg_name|
          attr_accessor arg_name
        end
      end
    end
  end

  def initialize(*args)
    args.each_with_index do |attribute_value, i|
      attribute_name = self.class.members[i]
      public_send("#{attribute_name}=", attribute_value)
    end
  end
end



class MyStructTest < Minitest::Test
  User = MyStruct.new(:first_name, :last_name)
  InternationalUser = MyStruct.new(:first_name, :last_name)

  class InternationalUser
    def initialize(first_name, second_name, third_name, last_name)
      @second_name = second_name
      @third_name = third_name
      super(first_name, last_name)
    end

    attr_reader :second_name, :third_name
  end

  def test_returns_a_new_class
    assert_equal Class, User.class
  end

  def test_args_are_assigned_to_members
    assert_equal :first_name, User.members[0]
    assert_equal :last_name, User.members[1]
  end

  def test_supports_all_arguments
    user = User.new("Jackie", "Chan")
    assert_equal "Jackie", user.first_name
    assert_equal "Chan", user.last_name
  end

  def test_supports_partial_arguments
    user2 = User.new("Bruce Lee")
    assert_equal "Bruce Lee", user2.first_name
  end

  def test_supports_opening_class_for_initialize_override
    intl_user = InternationalUser.new("Pablo", "Emilio", "Escobar", "Gaviria")
    assert_equal "Pablo", intl_user.first_name
    assert_equal "Emilio", intl_user.second_name
    assert_equal "Escobar", intl_user.third_name
    assert_equal "Gaviria", intl_user.last_name
  end
end
