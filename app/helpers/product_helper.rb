module ProductHelper
  # Map cup sizes to compatible lid sizes
  LID_SIZE_MAP = {
    '4oz' => '62mm',
    '6oz' => '80mm',
    '8oz' => '80mm',
    '10oz' => '90mm',
    '12oz' => '90mm',
    '16oz' => '90mm',
    '20oz' => '90mm'
  }.freeze

  def compatible_lids_for_cup(cup_size)
    lid_size = LID_SIZE_MAP[cup_size]
    return [] unless lid_size

    # Fetch from Hot Cups Extras category
    hot_cups_extras = Category.find_by(slug: 'hot-cups-extras')
    return [] unless hot_cups_extras

    # Find all lid products that have variants matching the size
    hot_cups_extras.products
                   .where("name LIKE ?", "%Lid%")
                   .includes(:active_variants, image_attachment: :blob)
                   .select { |product|
                     product.active_variants.any? { |variant|
                       variant.name.include?(lid_size)
                     }
                   }
  end
end
