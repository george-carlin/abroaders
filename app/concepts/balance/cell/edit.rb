class Balance < Balance.superclass
  module Cell
    class Edit < New
      def title
        'Edit balance'
      end
    end
  end
end
