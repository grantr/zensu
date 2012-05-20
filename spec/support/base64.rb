RSpec::Matchers.define :be_base64 do
  match do |actual|
    actual =~ /^[A-Za-z0-9\/=\n]+$/
  end
end
