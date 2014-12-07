require 'guard/compat/test/helper'
require 'guard/jammit'

RSpec.describe Guard::Jammit do
  let(:guard)    { Guard::Jammit.new }
  let(:defaults) { Guard::Jammit::DEFAULT_OPTIONS }

  before do
    allow(Guard::Compat::UI).to receive(:notify)
    allow(Guard::Compat::UI).to receive(:info)
    allow(Guard::Compat::UI).to receive(:error)
  end

  describe '#initialize' do
    context 'when no options are provided' do
      it 'sets a default :config_path option' do
        expected = File.join(Dir.pwd, 'config/assets.yml')
        expect(guard.options[:config_path]).to eql expected
      end

      it 'sets a default :output_folder option' do
        expect(guard.options[:output_folder]).to be nil
      end

      it 'sets a default :base_url option' do
        expect(guard.options[:base_url]).to be nil
      end

      it 'sets a default :public_root option' do
        expect(guard.options[:public_root]).to be nil
      end

      it 'sets a default :force option' do
        expect(guard.options[:force]).to eql false
      end

      it 'sets a default :package_names option' do
        expect(guard.options[:package_names]).to be nil
      end

      it 'sets a default :package_on_start option' do
        expect(guard.options[:package_on_start]).to eql true
      end

      it 'sets a default :notification option' do
        expect(guard.options[:notification]).to eql true
      end

      it 'sets a default :hide_success option' do
        expect(guard.options[:hide_success]).to eql false
      end
    end

    context 'with other options than the default ones' do
      let(:guard) do
        Guard::Jammit.new(config_path: 'assets.prod.yml',
                          output_folder: '/tmp',
                          base_url: 'http://www.site.com',
                          public_root: 'htdocs',
                          force: true,
                          package_names: [:admin],
                          package_on_start: false,
                          notification: false,
                          hide_success: true)
      end

      it 'sets the :config_path option' do
        expect(guard.options[:config_path]).to eql 'assets.prod.yml'
      end

      it 'sets the :output_folder option' do
        expect(guard.options[:output_folder]).to eql '/tmp'
      end

      it 'sets the :base_url option' do
        expect(guard.options[:base_url]).to eql 'http://www.site.com'
      end

      it 'sets the :public_root option' do
        expect(guard.options[:public_root]).to eql 'htdocs'
      end

      it 'sets the :force option' do
        expect(guard.options[:force]).to eql true
      end

      it 'sets the :package_names option' do
        expect(guard.options[:package_names]).to eql [:admin]
      end

      it 'sets the :package_on_start option' do
        expect(guard.options[:package_on_start]).to eql false
      end

      it 'sets the :notification option' do
        expect(guard.options[:notification]).to eql false
      end

      it 'sets the :hide_success option' do
        expect(guard.options[:hide_success]).to eql true
      end
    end
  end

  describe '#start' do
    before { allow(guard).to receive(:jammit) }

    it 'ensures that a partial Rails env is loaded' do
      expect(guard).to receive(:ensure_rails_env!)
      guard.start
    end

    context 'with :package_on_start on' do
      let(:guard) { Guard::Jammit.new(package_on_start: true) }

      it 'starts the packager' do
        expect(guard).to receive(:jammit)
        guard.start
      end
    end

    context 'with :package_on_start off' do
      let(:guard) { Guard::Jammit.new(package_on_start: false) }

      it 'starts the packager' do
        expect(guard).not_to receive(:jammit)
        guard.start
      end
    end
  end

  describe '#run_all' do
    before { allow(guard).to receive(:jammit) }

    it 'starts the packager' do
      expect(guard).to receive(:jammit)
      guard.run_all
    end
  end

  describe '#run_on_changes' do
    before { allow(guard).to receive(:jammit) }

    it 'starts the packager' do
      expect(guard).to receive(:jammit)
      guard.run_all
    end
  end

  describe '#jammit' do
    before { allow(::Jammit).to receive(:package!) }

    it 'clears the Jammit packager' do
      Thread.current[:jammit_packager] = true
      guard.jammit
      expect(Thread.current[:jammit_packager]).to be nil
    end

    it 'starts the asset packager' do
      expect(::Jammit).to receive(:package!)
      guard.jammit
    end

    context 'for a successfull operation' do
      it 'shows a success message' do
        expect(Guard::Compat::UI).to receive(:info).with('Jammit successfully packaged the assets.')
        guard.jammit
      end

      context 'with notifications' do
        context 'without hiding the success notification' do
          let(:guard) { Guard::Jammit.new(notification: true, hide_success: false) }

          it 'shows the success notification' do
            expect(Guard::Compat::UI).to receive(:notify).with('Jammit successfully packaged the assets.', title: 'Jammit')
            guard.jammit
          end
        end

        context 'with hiding the success notification' do
          let(:guard) { Guard::Jammit.new(notification: true, hide_success: true) }

          it 'does not show the success notification' do
            expect(Guard::Compat::UI).not_to receive(:notify)
            guard.jammit
          end
        end
      end

      context 'without notifications' do
        let(:guard) { Guard::Jammit.new(notification: false) }

        it 'does not show the success notification' do
          expect(Guard::Compat::UI).not_to receive(:notify)
          guard.jammit
        end
      end
    end

    context 'for a failed operation' do
      before { allow(::Jammit).to receive(:package!).and_raise('A Jammit error') }

      it 'shows a failure message' do
        expect(Guard::Compat::UI).to receive(:error).with('Jammit failed to package the assets: A Jammit error')
        guard.jammit
      end

      context 'with notifications' do
        let(:guard) { Guard::Jammit.new(notification: true) }

        it 'shows the failure notification' do
          expect(Guard::Compat::UI).to receive(:notify).with('Jammit failed to package the assets.', title: 'Jammit', image: :failed)
          guard.jammit
        end
      end

      context 'without notifications' do
        let(:guard) { Guard::Jammit.new(notification: false) }

        it 'does not show the failure notification' do
          expect(Guard::Compat::UI).not_to receive(:notify)
          guard.jammit
        end
      end
    end
  end
end
