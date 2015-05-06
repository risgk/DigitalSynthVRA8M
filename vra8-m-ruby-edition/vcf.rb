require './common'
require './lpf-table'

class VCF
  def initialize
    @cutoff = 127
    @resonance = OFF
    @eg_amt = 0
    @x1 = 0
    @x2 = 0
    @y1 = 0
    @y2 = 0
  end

  def set_cutoff(cutoff)
    @cutoff = cutoff
  end

  def set_resonance(resonance)
    @resonance = resonance
  end

  def set_eg_amt(eg_amt)
    @eg_amt = eg_amt
  end

  def clock(a, k)
    cutoff = @cutoff + high_byte(@eg_amt * (k << 1))
    if (cutoff > 127)
      cutoff = 127
    end

    if ((@resonance & 0x40) != 0)
      i = cutoff * 3
      b2_over_a0   = $lpf_table_q_2_sqrt_2[i + 0]
      a1_over_a0_i = $lpf_table_q_2_sqrt_2[i + 1]
      a2_over_a0   = $lpf_table_q_2_sqrt_2[i + 2]
    else
      i = cutoff * 3
      b2_over_a0   = $lpf_table_q_1_over_sqrt_2[i + 0]
      a1_over_a0_i = $lpf_table_q_1_over_sqrt_2[i + 1]
      a2_over_a0   = $lpf_table_q_1_over_sqrt_2[i + 2]
    end

    x0 = a << 8
    r = x0 + (@x1 << 1) + @x2
    tmp = -muls_16(a2_over_a0, @y2)
    tmp += muls_16(b2_over_a0, r)
    tmp += muls_16(a1_over_a0_i, @y1)
    y0 = tmp << (0x8000 / LPF_TABLE_ONE)
    @x2 = @x1
    @y2 = @y1
    @x1 = x0
    @y1 = y0

    return high_byte(y0)
  end
end