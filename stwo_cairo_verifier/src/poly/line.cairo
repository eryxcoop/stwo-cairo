use core::option::OptionTrait;
use core::clone::Clone;
use core::result::ResultTrait;
use stwo_cairo_verifier::fields::SecureField;
use stwo_cairo_verifier::poly::utils::fold;
use stwo_cairo_verifier::circle::CirclePointTrait;
use stwo_cairo_verifier::fields::m31::{M31, m31};
use stwo_cairo_verifier::utils::{pow, bit_reverse_index};
use stwo_cairo_verifier::circle::{Coset, CosetImpl};
use stwo_cairo_verifier::fields::m31::M31Trait;
use stwo_cairo_verifier::poly::circle::{CircleDomain, CircleDomainImpl};
use stwo_cairo_verifier::fri::query::{Queries, QueriesImpl};
use stwo_cairo_verifier::fields::qm31::{QM31, qm31};
use stwo_cairo_verifier::poly::circle::{
    CircleEvaluation, SparseCircleEvaluation, SparseCircleEvaluationImpl
};
use stwo_cairo_verifier::fri::folding::fold_line;

/// A univariate polynomial represented by its coefficients in the line part of the FFT-basis
/// in bit reversed order.
#[derive(Debug, Drop, Clone)]
pub struct LinePoly {
    pub coeffs: Array<SecureField>,
    pub log_size: u32,
}

#[generate_trait]
pub impl LinePolyImpl of LinePolyTrait {
    fn len(self: @LinePoly) -> usize {
        self.coeffs.len()
    }

    fn eval_at_point(self: @LinePoly, mut x: SecureField) -> SecureField {
        let mut doublings = array![];
        let mut i = 0;
        while i < *self.log_size {
            doublings.append(x);
            let x_square = x * x;
            x = x_square + x_square - m31(1).into();
            i += 1;
        };

        fold(self.coeffs, @doublings, 0, 0, self.coeffs.len())
    }
}


#[derive(Copy, Drop, Debug)]
pub struct LineDomain {
    pub coset: Coset,
}


#[generate_trait]
pub impl LineDomainImpl of LineDomainTrait {
    fn new(coset: Coset) -> LineDomain {
        // TODO: Implement assertions.
        LineDomain { coset: coset }
    }

    fn double(self: @LineDomain) -> LineDomain {
        LineDomain { coset: self.coset.double() }
    }

    fn at(self: @LineDomain, index: usize) -> M31 {
        self.coset.at(index).x
    }

    fn log_size(self: @LineDomain) -> usize {
        *self.coset.log_size
    }

    fn size(self: @LineDomain) -> usize {
        self.coset.size()
    }
}


#[derive(Drop)]
pub struct LineEvaluation {
    pub values: Array<QM31>,
    pub domain: LineDomain
}


#[derive(Drop)]
pub struct SparseLineEvaluation {
    pub subline_evals: Array<LineEvaluation>,
}

#[generate_trait]
pub impl LineEvaluationImpl of LineEvaluationTrait {
    fn new(domain: LineDomain, values: Array<QM31>) -> LineEvaluation {
        assert_eq!(values.len(), domain.size());
        LineEvaluation { values: values, domain: domain }
    }
}

#[generate_trait]
pub impl SparseLineEvaluationImpl of SparseLineEvaluationTrait {
    fn fold(self: @SparseLineEvaluation, alpha: QM31) -> Array<QM31> {
        let mut i = 0;
        let mut res: Array<QM31> = array![];
        while i < self.subline_evals.len() {
            let line_evaluation = fold_line(self.subline_evals[i], alpha);
            res.append(*line_evaluation.values.at(0));
            i += 1;
        };
        return res;
    }
}

#[cfg(test)]
mod tests {
    use super::{LinePoly, LinePolyTrait};
    use stwo_cairo_verifier::fields::qm31::qm31;
    use stwo_cairo_verifier::fields::m31::m31;

    #[test]
    fn test_eval_at_point_1() {
        let line_poly = LinePoly {
            coeffs: array![
                qm31(1080276375, 1725024947, 477465525, 102017026),
                qm31(1080276375, 1725024947, 477465525, 102017026)
            ],
            log_size: 1
        };
        let x = m31(590768354);
        let result = line_poly.eval_at_point(x.into());
        let expected_result = qm31(515899232, 1030391528, 1006544539, 11142505);
        assert_eq!(expected_result, result);
    }

    #[test]
    fn test_eval_at_point_2() {
        let line_poly = LinePoly {
            coeffs: array![qm31(1, 2, 3, 4), qm31(5, 6, 7, 8)], log_size: 1
        };
        let x = m31(10);
        let result = line_poly.eval_at_point(x.into());
        let expected_result = qm31(51, 62, 73, 84);
        assert_eq!(expected_result, result);
    }

    #[test]
    fn test_eval_at_point_3() {
        let poly = LinePoly {
            coeffs: array![
                qm31(1, 2, 3, 4),
                qm31(5, 6, 7, 8),
                qm31(9, 10, 11, 12),
                qm31(13, 14, 15, 16),
                qm31(17, 18, 19, 20),
                qm31(21, 22, 23, 24),
                qm31(25, 26, 27, 28),
                qm31(29, 30, 31, 32),
            ],
            log_size: 3
        };
        let x = qm31(2, 5, 7, 11);

        let result = poly.eval_at_point(x);

        let expected_result = qm31(1857853974, 839310133, 939318020, 651207981);
        assert_eq!(expected_result, result);
    }
}
