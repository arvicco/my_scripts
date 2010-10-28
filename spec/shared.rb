shared_examples_for "script with args" do

  it 'displays usage and exits if no args given' do
    stdout_should_receive :pattern, Regexp.new("Script #{@name} .* - Usage:")
    expect{ cli "#{@name}" }.to raise_error SystemExit
  end
end