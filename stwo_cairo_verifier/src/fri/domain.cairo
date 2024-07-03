use core::option::OptionTrait;
use core::clone::Clone;
use core::result::ResultTrait;
use stwo_cairo_verifier::fields::m31::{M31, m31};


#[derive(Copy, Debug, PartialEq, Eq, Drop)]
pub struct CirclePointIndex {
    pub index: usize
}

#[derive(Copy, Clone, Debug, PartialEq, Eq, Drop)]
pub struct Coset {
    pub initial_index: CirclePointIndex,
    //pub initial: CirclePoint<M31>,
    pub step_size: CirclePointIndex,
    //pub step: CirclePoint<M31>,
    pub log_size: u32,
}

#[derive(Copy, Drop)]
pub struct LineDomain {
    pub coset: Coset,
}

#[derive(Copy, Drop)]
pub struct CircleDomain {
    pub half_coset: Coset
}

pub fn dummy_line_domain() -> LineDomain {
    LineDomain {
        coset: Coset {
            initial_index: CirclePointIndex { index: 0 },
            step_size: CirclePointIndex { index: 0 },
            log_size: 1
        }
    }
}

#[generate_trait]
pub impl CosetImpl of CosetTrait {
    fn index_at(self: @Coset, index: usize) -> CirclePointIndex {
        let initial_index = *self.initial_index.index;
        let step_size = *self.step_size.index;
        let index_times_step = (core::integer::u32_wide_mul(step_size, index) & 0x7fffffff)
            .try_into()
            .unwrap();
        let result = core::integer::u32_wrapping_add(initial_index, index_times_step) & 0x7fffffff;
        CirclePointIndex { index: result }
    }

    fn new(_initial_index: CirclePointIndex, log_size: u32) -> Coset {
        // TODO: implement
        Coset {
            initial_index: CirclePointIndex { index: 0 },
            step_size: CirclePointIndex { index: 0 },
            log_size: 1
        }
    }
}

#[generate_trait]
pub impl LineDomainImpl of LineDomainTrait {
    fn new(coset: Coset) -> LineDomain {
        // TODO: Implement, it does some assertions.
        LineDomain { coset: coset }
    }
    fn double(self: LineDomain) -> LineDomain {
        // TODO: implement
        self
    }

    fn at(self: @LineDomain, index: usize) -> M31 {
        // TODO: implement
        m31(1)
    }

    fn log_size(self: @LineDomain) -> usize {
        // TODO: implement
        1
    }
}


#[test]
fn test_coset_index_at() {
    let coset = Coset {
        initial_index: CirclePointIndex { index: 16777216 },
        log_size: 5,
        step_size: CirclePointIndex { index: 67108864 }
    };
    let result = coset.index_at(8);
    let expected_result = CirclePointIndex { index: 553648128 };
    assert_eq!(expected_result, result);
}
