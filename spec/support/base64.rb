RSpec::Matchers.define :be_base64 do
  # RFC4648 defines base64 as:
  # A-Z
  # a-z
  # 0-9
  # /
  # +
  # = (padding character)
  match do |actual|
    actual =~ /^[A-Za-z0-9\/\+=]+$/
  end
end
