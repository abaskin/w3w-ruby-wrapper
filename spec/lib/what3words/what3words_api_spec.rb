# encoding: utf-8

require "spec_helper"
require "yaml"

describe What3Words::API, "integration", :integration => true do

  before(:all) do
    WebMock.allow_net_connect!
  end

  let!(:config) do
    file = "spec/config.yaml"
    if ! File.exist? file
      raise "Add a file #{file} (use spec/config.sample.yaml as a template) with correct values to run integration specs"
    end
    YAML.load_file file
  end

  let(:api_key) { config["api_key"] }

  let(:w3w) { described_class.new(:key => api_key) }

  it "returns errors from API" do
    badw3w = described_class.new(:key => "")
    expect { badw3w.forward ["prom", "cape", "pump"] }.
      to raise_error described_class::ResponseError
  end

  describe "getting position" do

    it "works with string of 3 words separated by '.'" do
      result = w3w.forward "prom.cape.pump"
      expect(result).to include(
        :words => "prom.cape.pump",
        :geometry => { :lat => 51.484463, :lng => -0.195405 },
        :language => "en"
      )
    end

    it "sends lang parameter for 3 words" do
      result = w3w.forward ["prom", "cape", "pump"], :lang => "fr"
      expect(result).to include(
        :words => "concevoir.époque.amasser",
        :geometry => { :lat => 51.484463, :lng => -0.195405 },
        :language => "fr"
      )
    end

    it "checks 3 words format matches standard regex" do
      expect { w3w.forward "1.cape.pump" }.
        to raise_error described_class::WordError
    end

  end

  describe "gets 3 words" do
    it "from position" do
      result = w3w.reverse [29.567041, 106.587875]
      expect(result).to include(
        :words => "disclose.strain.redefined",
        :geometry => { :lat => 29.567041, :lng => 106.587875 },
        :language => "en"
      )
    end

    it "from position in fr" do
      result = w3w.reverse [29.567041, 106.587875], :lang => "fr"
      expect(result).to include(
        :words => "courgette.spécieuse.infrason",
        :geometry => { :lat => 29.567041, :lng => 106.587875 },
        :language => "fr"
      )
    end

  end

  it "gets languages" do
    result = w3w.languages
    # expect(result[:languages]).to include(
    #   :code => "fr"
    # )
  end

  it "'s deep_symbolize_keys helper works" do
    expect(w3w.deep_symbolize_keys("foo" => {"bar" => true})).
      to eq(:foo => {:bar => true})
  end
end