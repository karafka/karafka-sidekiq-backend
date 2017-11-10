# frozen_string_literal: true

# Test module that we use to check namespaced controllers
module TestModule
end

RSpec.describe Karafka::Workers::Builder do
  subject(:builder) { described_class.new(controller_class) }

  let(:controller_class) { double }

  describe '.new' do
    it 'assigns internally controller_class' do
      expect(builder.instance_variable_get('@controller_class')).to eq controller_class
    end
  end

  describe '#build' do
    let(:base) { Karafka::BaseWorker }

    before do
      allow(builder)
        .to receive(:base)
        .and_return(base)
    end

    context 'when the worker class already exists' do
      before { worker_class }

      context 'when it is on a root level' do
        let(:controller_class) do
          class SuperController
            self
          end
        end

        let(:worker_class) do
          class SuperWorker
            self
          end
        end

        it { expect(builder.build).to eq worker_class }
      end

      context 'when it is in a module/class' do
        let(:controller_class) do
          module TestModule
            class SuperController
              self
            end
          end
        end

        let(:worker_class) do
          module TestModule
            class SuperWorker
              self
            end
          end
        end

        it { expect(builder.build).to eq worker_class }
      end

      context 'when it is anonymous' do
        let(:controller_class) { Class.new }
        let(:worker_class) { nil }

        it { expect(builder.build).to be < Karafka::BaseWorker }
      end
    end

    context 'when a given worker class does not exist' do
      context 'when it is on a root level' do
        let(:controller_class) do
          class SuperSadController
            self
          end
        end

        it 'expect to build it' do
          expect(builder.build.to_s).to eq 'SuperSadWorker'
        end

        it { expect(builder.build).to be < Karafka::BaseWorker }
      end

      context 'when it is in a module/class' do
        let(:controller_class) do
          module TestModule
            class SuperSad2Controller
              self
            end
          end
        end

        it 'expect to build it' do
          expect(builder.build.to_s).to eq 'TestModule::SuperSad2Worker'
        end

        it { expect(builder.build).to be < Karafka::BaseWorker }
      end
    end
  end

  describe '#base' do
    before do
    end

    context 'when there is a direct descendant of Karafka::BaseWorker' do
      let(:descendant) { double }

      it 'expect to use it' do
        expect(Karafka::BaseWorker).to receive(:subclasses).and_return([descendant])
        expect(builder.send(:base)).to eq descendant
      end
    end

    context 'when there is no direct descendant of Karafka::BaseWorker' do
      let(:descendant) { nil }
      let(:error) { Karafka::Errors::BaseWorkerDescentantMissing }

      it 'expect to fail' do
        expect(Karafka::BaseWorker).to receive(:subclasses).and_return([descendant])
        expect { builder.send(:base) }.to raise_error(error)
      end
    end
  end

  describe '#matcher' do
    it { expect(builder.send(:matcher)).to be_a Karafka::Helpers::ClassMatcher }
  end
end
