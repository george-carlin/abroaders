require 'rails_helper'

describe Alliance::Create do
  describe 'valid save' do
    describe 'unspecified order' do
      example 'no existing alliances' do
        res, op = described_class.run(alliance: { name: 'My Alliance' })
        expect(res).to be true

        alliance = op.model
        expect(alliance.name).to eq 'My Alliance'
        expect(alliance.order).to eq 1 # automatically uses next available order
      end

      example 'existing alliances' do
        create(:alliance, order: 1)
        create(:alliance, order: 2)
        res, op = described_class.run(alliance: { name: 'My Alliance' })
        expect(res).to be true

        alliance = op.model
        expect(alliance.name).to eq 'My Alliance'
        expect(alliance.order).to eq 3 # automatically uses next available order
      end
    end

    example 'with order' do
      res, op = described_class.run(alliance: { name: 'My Alliance', order: 3 })
      expect(res).to be true

      alliance = op.model
      expect(alliance.name).to eq 'My Alliance'
      expect(alliance.order).to eq 3
    end

    example 'strips whitespace' do
      res, op = described_class.run(alliance: { name: '   Yo   ' })
      raise unless res
      expect(op.model.name).to eq 'Yo'
    end
  end

  example 'invalid save' do
    res, = described_class.run(alliance: { name: ' ' })
    expect(res).to be false
  end
end
