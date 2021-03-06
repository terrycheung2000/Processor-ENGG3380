
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ALUReg is
    Port ( DataIn : in STD_LOGIC_VECTOR (15 downto 0):= "0000000000000000";
           DataOut : out STD_LOGIC_VECTOR (15 downto 0):= "0000000000000000";
           clk, en : in STD_LOGIC);
end ALUReg;

architecture Behavioral of ALUReg is
type registerArray is array(0 to 0) of std_logic_vector(15 downto 0);
signal registers : registerArray := (others=> "0000000000000000" ); --initializes to xero
begin
-- Read Data
        DataOut <= registers(0);
process (CLK)
  begin
    if falling_edge(CLK) then
      
      -- Write Data
      if(en = '1') then
        registers(0) <= DataIn;  -- Write data to specified register
        end if;
    end if;
  end process;

end Behavioral;
