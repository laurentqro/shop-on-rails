class RenameImageToProductPhoto < ActiveRecord::Migration[8.1]
  def up
    # Rename 'image' attachments to 'product_photo' for Products and ProductVariants
    ActiveStorage::Attachment.where(
      record_type: [ 'Product', 'ProductVariant' ],
      name: 'image'
    ).update_all(name: 'product_photo')
  end

  def down
    # Rollback: rename 'product_photo' back to 'image'
    ActiveStorage::Attachment.where(
      record_type: [ 'Product', 'ProductVariant' ],
      name: 'product_photo'
    ).update_all(name: 'image')
  end
end
