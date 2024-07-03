use stwo_cairo_verifier::fields::qm31::{QM31, qm31};

pub fn bit_reverse_index(mut index: usize, mut bits: u32) -> usize {
    assert!(bits < 32);
    let mut result = 0;
    let mut pow_of_two = 1;
    while bits > 0 {
        result *= 2;
        result = result | ((index / pow_of_two) & 1);
        pow_of_two *= 2;
        bits -= 1;
    };
    result
}

pub fn pow(base: u32, exponent: u32) -> u32 {
    // TODO: implement or include from alexandria
    1
}

pub fn pow_qm31(base: QM31, exponent: u32) -> QM31 {
    // TODO: implement
    qm31(1, 0, 0, 0)
}

pub fn qm31_zero_array(n: u32) -> Array<QM31> {
    let mut result = array![];
    let mut i = 0;
    while i < n {
        result.append(qm31(0, 0, 0, 0));
        i += 1;
    };
    result
}


#[test]
fn test_bit_reverse() {
    // 1 bit
    assert_eq!(0, bit_reverse_index(0, 1));
    assert_eq!(1, bit_reverse_index(1, 1));

    // 2 bits
    assert_eq!(0, bit_reverse_index(0, 2));
    assert_eq!(2, bit_reverse_index(1, 2));
    assert_eq!(1, bit_reverse_index(2, 2));
    assert_eq!(3, bit_reverse_index(3, 2));

    // 3 bits
    assert_eq!(0, bit_reverse_index(0, 3));
    assert_eq!(4, bit_reverse_index(1, 3));
    assert_eq!(2, bit_reverse_index(2, 3));
    assert_eq!(6, bit_reverse_index(3, 3));

    // 16 bits
    assert_eq!(24415, bit_reverse_index(64250, 16));

    // 31 bits
    assert_eq!(16448250, bit_reverse_index(800042880, 31));
}
