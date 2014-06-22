# Format query results
#
# Query results are ordinarily returned as a list of Address instances. This
# is useful for processing the data in a structured way, but the user may 
# simply wish for a properly formatted address to be returned.
#
# This class formats an address in accordance with the Royal Mail
# guidance on formatting addresses. See page 27 of the Programmers' Guide to 
# the PAF: http://www.royalmail.com/sites/default/files/docs/pdf/programmers_guide_edition_7_v5.pdf
class AddressFormatter

  # Format address
  #
  # Formats the address in the required manner.
  #
  # @param [Address, Hash] address  An Address instance or hash containing 
  #                                 address data.
  # @param [String] delimiter       The character to use between address 
  #                                 lines.
  # @return [String] Properly formatted address
  def self.format_address(address, delimiter="\n")
    # Create empty string for storing address.
    addr_lines = ""
  
    # Begin with department, organisation & PO Box number, if applicable.
    [:department, :organisation, :po_box].each do |key|
      addr_lines << "#{address[key]}\n" unless address[key].to_s.empty?
    end
    # Format building name/number components.
    addr_lines   << format_building(*[:sub_building_name, 
                                      :building_name, 
                                      :building_number, 
                                      :concat_indicator].map { |k| address[k] })
    # Add thoroughfare, locality, town & postcode.
    [:dependent_thoroughfare, :thoroughfare, 
     :dbl_dependent_locality, :dependent_locality, 
     :town,                   :postcode].each do |key|
       if key == :town
         addr_lines << "#{address[key].upcase}\n"
       else
         addr_lines << "#{address[key]}\n" unless address[key].to_s.empty?
       end
     end
     addr_lines.strip
  end

  private

  # Format building components
  #
  # Properly format the building name & number components, in accordance with 
  # the rules laid down in the Royal Mail's Programmer's Guide.
  #
  # @param [String] sub_name  Building Sub-Name component
  # @param [String] name      Building Name component
  # @param [Integer] number   Building Number component
  # @param [String] concat    Concatenation Indicator component
  # @return [Array]           All components properly formatted & joined, in an 
  #                           array in which each row represents one line of 
  #                           the address.
  def self.format_building(sub_name, name, number, concat)
    case
    # If name/numbers are empty, return an empty string.
    when (sub_name.to_s.empty?) && 
         (name.to_s.empty?) && 
         (number.to_s.empty?)
      return ""
    # If concatenation indicator, then just concat and return.
    when concat == "Y"
      return "#{number || ''}#{sub_name.length > 1 ? ' ' : ''}#{sub_name} "
    end
    # Define exception to the usual rule requiring a newline for the building 
    # name. See p. 27 of PAF Guide for further information.
    building_str = ""
    exception    = /^\d.*\d$|^\d.*\d[A-Za-z]$|^\d[A-Za-z]$|^.$/
    [sub_name, name].reject { |x| x.nil? }.each do |component|
      if component =~ exception
        building_str << component
        building_str << (component =~ /^[[:alpha:]]$/ ? ", " : " ")
      else
        # Check if final portion of string is numeric/alphanumeric. If so, 
        # split and apply exception to that section only. However, don't do 
        # this if the name has specific prefix.
        prefixes  = ['Back of', 'Block', 'Blocks', 'Building', 'Maisonette', 
                     'Maisonettes', 'Rear Of', 'Shop', 'Shops', 'Stall', 
                     'Stalls', 'Suite', 'Suites', 'Unit', 'Units']
        parts     = component.split(' ')
        final     = parts.pop
        if final =~ exception && number.nil? && final !~ /^\d*$/ && 
           !prefixes.include?(parts.join(' '))
          building_str << "#{parts.join(' ')}\n#{final} "
        else
          building_str << "#{component}\n"
        end
      end
    end
    building_str << "#{number} " unless number.nil?
    building_str.lstrip
  end
end
