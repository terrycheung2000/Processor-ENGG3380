
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AReg is
    Port ( DataIn : in STD_LOGIC_VECTOR (15 downto 0):= "0000000000000000";
           DataOut : out STD_LOGIC_VECTOR (15 downto 0):= "0000000000000000";
               CLK, en : in std_logic);
end AReg;

architecture Behavioral of AReg is
type registerArray is array(0 to 0) of std_logic_vector(15 downto 0);
signal registers : registerArray := (others=> "0000000000000000" ); --initializes to xero
begin
DataOut <= registers(0);
process (CLK)
  begin
    if falling_edge(CLK) then
      -- Read Data
        
      -- Write Data
      if(en = '1') then
        registers(0) <= DataIn;  -- Write data to specified register
        end if;
    end if;
  end process;


end Behavioral;
