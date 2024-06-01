# frozen_string_literal: true

RSpec.describe Envy do
  describe ".from_file" do
    it "sets file permissions" do
      described_class.from_file ENV_FILE, ENV_DEV_FILE, "nop.yml"

      expect(File::Stat.new(ENV_FILE).mode.to_s(8)[-3..]).to eq("600")
      expect(File::Stat.new(ENV_DEV_FILE).mode.to_s(8)[-3..]).to eq("600")
    end

    context "when env vars do not exist" do
      it "loads env vars from YAML file" do
        described_class.from_file ENV_FILE

        expect(ENV["APP_DATABASE_HOST"]).to eq("grottopress.com")
        expect(ENV["APP_DATABASE_PORT"]).to eq("5432")
        expect(ENV["APP_SERVER_HOSTS_0"]).to eq("grottopress.com")
        expect(ENV["APP_SERVER_HOSTS_1"]).to eq("itechplus.org")
        expect(ENV["APP_SERVER_PORT"]).to eq("80")
      end
    end

    context "when env vars exist" do
      it "does not overwrite existing env vars" do
        ENV["APP_DATABASE_HOST"] = "abc.com"
        ENV["APP_DATABASE_PORT"] = "1234"
        ENV["APP_SERVER_HOSTS_0"] = "abc.net"
        ENV["APP_SERVER_HOSTS_1"] = "abc.org"

        described_class.from_file ENV_FILE

        expect(ENV["APP_DATABASE_HOST"]).to eq("abc.com")
        expect(ENV["APP_DATABASE_PORT"]).to eq("1234")
        expect(ENV["APP_SERVER_HOSTS_0"]).to eq("abc.net")
        expect(ENV["APP_SERVER_HOSTS_1"]).to eq("abc.org")
        expect(ENV["APP_SERVER_PORT"]).to eq("80")
      end
    end

    context "when given multiple files" do
      it "loads the first readable file" do
        described_class.from_file "nop.yml", ENV_DEV_FILE, ENV_FILE

        expect(ENV["APP_DATABASE_HOST"]).to eq("localhost")
        expect(ENV["APP_DATABASE_PORT"]).to eq("4321")
        expect(ENV["APP_SERVER_HOSTS_0"]).to eq("localhost")
        expect(ENV["APP_SERVER_HOSTS_1"]).to eq("grottopress.localhost")
        expect(ENV["APP_SERVER_PORT"]).to eq("8080")
      end
    end

    context "when given non-existent files" do
      it "raises an exception" do
        expect { described_class.from_file "nop.yml", "nop2.yml" }
          .to raise_error(Envy::Error)
      end
    end
  end

  describe ".from_file!" do
    it "sets file permissions" do
      described_class.from_file! ENV_DEV_FILE, ENV_FILE, "nop.yml", perm: 0o400

      expect(File::Stat.new(ENV_FILE).mode.to_s(8)[-3..]).to eq("400")
      expect(File::Stat.new(ENV_DEV_FILE).mode.to_s(8)[-3..]).to eq("400")
    end

    context "when env vars do not exist" do
      it "loads env vars from yaml file" do
        described_class.from_file! ENV_FILE

        expect(ENV["APP_DATABASE_HOST"]).to eq("grottopress.com")
        expect(ENV["APP_DATABASE_PORT"]).to eq("5432")
        expect(ENV["APP_SERVER_HOSTS_0"]).to eq("grottopress.com")
        expect(ENV["APP_SERVER_HOSTS_1"]).to eq("itechplus.org")
        expect(ENV["APP_SERVER_PORT"]).to eq("80")
      end
    end

    context "when env vars exist" do
      it "overwrites existing env vars" do
        ENV["APP_DATABASE_HOST"] = "abc.com"
        ENV["APP_DATABASE_PORT"] = "1234"
        ENV["APP_SERVER_HOSTS_0"] = "abc.net"
        ENV["APP_SERVER_HOSTS_1"] = "abc.org"

        described_class.from_file! ENV_FILE

        expect(ENV["APP_DATABASE_HOST"]).to eq("grottopress.com")
        expect(ENV["APP_DATABASE_PORT"]).to eq("5432")
        expect(ENV["APP_SERVER_HOSTS_0"]).to eq("grottopress.com")
        expect(ENV["APP_SERVER_HOSTS_1"]).to eq("itechplus.org")
        expect(ENV["APP_SERVER_PORT"]).to eq("80")
      end
    end

    context "when given multiple files" do
      it "loads the first readable file" do
        described_class.from_file! "nop.yml", ENV_DEV_FILE, ENV_FILE

        expect(ENV["APP_DATABASE_HOST"]).to eq("localhost")
        expect(ENV["APP_DATABASE_PORT"]).to eq("4321")
        expect(ENV["APP_SERVER_HOSTS_0"]).to eq("localhost")
        expect(ENV["APP_SERVER_HOSTS_1"]).to eq("grottopress.localhost")
        expect(ENV["APP_SERVER_PORT"]).to eq("8080")
      end
    end

    context "when given non-existent files" do
      it "raises an exception" do
        expect { described_class.from_file! "nop.yml", "nop2.yml" }
          .to raise_error(Envy::Error)
      end
    end
  end

  describe ".set_envs" do
    it "supports hashes nested under lists" do
      described_class.from_file ENV_FILE

      expect(ENV["APP_WEBHOOKS_0_URL"]).to eq("http://example.com")
      expect(ENV["APP_WEBHOOKS_0_TOKEN"]).to eq("a1b2c2")
      expect(ENV["APP_WEBHOOKS_1_URL"]).to eq("http://example.net")
      expect(ENV["APP_WEBHOOKS_1_TOKEN"]).to eq("d4e5f6")
    end

    context "when env file not loaded" do
      it "loads env file" do
        expect(ENV["ENVY_LOADED"]).to be_nil

        described_class.from_file ENV_FILE

        expect(ENV["ENVY_LOADED"]).to eq("yes")
        expect(ENV["APP_DATABASE_HOST"]).to eq("grottopress.com")
        expect(ENV["APP_DATABASE_PORT"]).to eq("5432")
        expect(ENV["APP_SERVER_HOSTS_0"]).to eq("grottopress.com")
        expect(ENV["APP_SERVER_HOSTS_1"]).to eq("itechplus.org")
        expect(ENV["APP_SERVER_PORT"]).to eq("80")
      end
    end

    context "when env file already loaded" do
      it "does not load env file again" do
        ENV["ENVY_LOADED"] = "yes"

        described_class.from_file ENV_FILE

        expect(ENV["APP_DATABASE_HOST"]).to be_nil
        expect(ENV["APP_DATABASE_PORT"]).to be_nil
        expect(ENV["APP_SERVER_HOSTS_0"]).to be_nil
        expect(ENV["APP_SERVER_HOSTS_1"]).to be_nil
        expect(ENV["APP_SERVER_PORT"]).to be_nil
      end
    end
  end
end
