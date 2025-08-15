require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  it 'inherits from ActiveJob::Base' do
    expect(ApplicationJob).to be < ActiveJob::Base
  end

  it 'can be instantiated' do
    expect { ApplicationJob.new }.not_to raise_error
  end
end
