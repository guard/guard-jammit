require 'spec_helper'

describe Guard::Jammit do

  let(:guard)    { Guard::Jammit.new }
  let(:defaults) { Guard::Jammit::DEFAULT_OPTIONS }

  before do
    Guard::Notifier.stub(:notify)
  end

  describe '#initialize' do
    context 'when no options are provided' do
      it 'sets a default :config_path option' do
        guard.options[:config_path].should eql "#{ @project_path }/config/assets.yml"
      end

      it 'sets a default :output_folder option' do
        guard.options[:output_folder].should be nil
      end

      it 'sets a default :base_url option' do
        guard.options[:base_url].should be nil
      end

      it 'sets a default :public_root option' do
        guard.options[:public_root].should be nil
      end

      it 'sets a default :force option' do
        guard.options[:force].should eql false
      end

      it 'sets a default :package_names option' do
        guard.options[:package_names].should be nil
      end

      it 'sets a default :package_on_start option' do
        guard.options[:package_on_start].should eql true
      end

      it 'sets a default :notification option' do
        guard.options[:notification].should eql true
      end

      it 'sets a default :hide_success option' do
        guard.options[:hide_success].should eql false
      end
    end

    context 'with other options than the default ones' do
      let(:guard) { Guard::Jammit.new(nil, { :config_path      => 'assets.prod.yml',
                                             :output_folder    => '/tmp',
                                             :base_url         => 'http://www.site.com',
                                             :public_root      => 'htdocs',
                                             :force            => true,
                                             :package_names    => [:admin],
                                             :package_on_start => false,
                                             :notification     => false,
                                             :hide_success     => true }) }

      it 'sets the :config_path option' do
        guard.options[:config_path].should eql 'assets.prod.yml'
      end

      it 'sets the :output_folder option' do
        guard.options[:output_folder].should eql '/tmp'
      end

      it 'sets the :base_url option' do
        guard.options[:base_url].should eql 'http://www.site.com'
      end

      it 'sets the :public_root option' do
        guard.options[:public_root].should eql 'htdocs'
      end

      it 'sets the :force option' do
        guard.options[:force].should eql true
      end

      it 'sets the :package_names option' do
        guard.options[:package_names].should eql [:admin]
      end

      it 'sets the :package_on_start option' do
        guard.options[:package_on_start].should eql false
      end

      it 'sets the :notification option' do
        guard.options[:notification].should eql false
      end

      it 'sets the :hide_success option' do
        guard.options[:hide_success].should eql true
      end
    end
  end

  describe '#start' do
    before { guard.stub(:jammit) }

    it 'ensures that a partial Rails env is loaded' do
      guard.should_receive(:ensure_rails_env!)
      guard.start
    end

    context 'with :package_on_start on' do
      let(:guard) { Guard::Jammit.new(nil, { :package_on_start => true }) }

      it 'starts the packager' do
        guard.should_receive(:jammit)
        guard.start
      end
    end

    context 'with :package_on_start off' do
      let(:guard) { Guard::Jammit.new(nil, { :package_on_start => false }) }

      it 'starts the packager' do
        guard.should_not_receive(:jammit)
        guard.start
      end
    end
  end

  describe '#run_all' do
    before { guard.stub(:jammit) }

    it 'starts the packager' do
      guard.should_receive(:jammit)
      guard.run_all
    end
  end

  describe '#run_on_changes' do
    before { guard.stub(:jammit) }

    it 'starts the packager' do
      guard.should_receive(:jammit)
      guard.run_all
    end
  end

  describe '#jammit' do
    before { ::Jammit.stub(:package!) }

    it 'clears the Jammit packager' do
      Thread.current[:jammit_packager] = true
      guard.jammit
      Thread.current[:jammit_packager].should be nil
    end

    it 'starts the asset packager' do
      ::Jammit.should_receive(:package!)
      guard.jammit
    end

    context 'for a successfull operation' do
      it 'shows a success message' do
        Guard::UI.should_receive(:info).with('Jammit successfully packaged the assets.')
        guard.jammit
      end

      context 'with notifications' do
        context 'without hiding the success notification' do
          let(:guard) { Guard::Jammit.new(nil, { :notification => true, :hide_success => false }) }

          it 'shows the success notification' do
            Guard::Notifier.should_receive(:notify).with('Jammit successfully packaged the assets.', :title => 'Jammit')
            guard.jammit
          end
        end

        context 'with hiding the success notification' do
          let(:guard) { Guard::Jammit.new(nil, { :notification => true, :hide_success => true }) }

          it 'does not show the success notification' do
            Guard::Notifier.should_not_receive(:notify)
            guard.jammit
          end
        end
      end

      context 'without notifications' do
        let(:guard) { Guard::Jammit.new(nil, { :notification => false }) }

        it 'does not show the success notification' do
          Guard::Notifier.should_not_receive(:notify)
          guard.jammit
        end
      end
    end

    context 'for a failed operation' do
      before { ::Jammit.stub(:package!).and_raise('A Jammit error') }

      it 'shows a failure message' do
        Guard::UI.should_receive(:error).with('Jammit failed to package the assets: A Jammit error')
        guard.jammit
      end

      context 'with notifications' do
        let(:guard) { Guard::Jammit.new(nil, { :notification => true }) }

        it 'shows the failure notification' do
          Guard::Notifier.should_receive(:notify).with('Jammit failed to package the assets.', :title => 'Jammit', :image => :failed)
          guard.jammit
        end
      end

      context 'without notifications' do
        let(:guard) { Guard::Jammit.new(nil, { :notification => false }) }

        it 'does not show the failure notification' do
          Guard::Notifier.should_not_receive(:notify)
          guard.jammit
        end
      end
    end

  end

end
