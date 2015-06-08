class AddSciNameToTaxons < ActiveRecord::Migration
  def change
   add_column :taxons,:sci_name, :string

  end
end
