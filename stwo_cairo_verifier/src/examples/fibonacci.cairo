
use stwo_cairo_verifier::pcs::verifier::CommitmentSchemeProof;

use stwo_cairo_verifier::poly::circle::{CircleDomainImpl, CircleEvaluation, CircleEvaluationImpl};
use stwo_cairo_verifier::fields::qm31::{QM31, qm31};
use stwo_cairo_verifier::utils::pow;


#[derive(Drop)]
struct StarkProof {
    commitments: Array<felt252>,
    commitment_scheme_proof: CommitmentSchemeProof,
}

//#[test]
fn generate_test_trace() -> Array<CircleEvaluation>{ //log_n_instances: u32, log_size: u32
    //necesito un domain de tamanio log_size
    let log_size = 3;
    let mut trace = array![qm31(1,0,0,0), qm31(1,0,0,0)];

    let size = pow(2_u32, log_size);
    let mut i = 0;
    while i < size {
        
        let mut next_fib = *trace[trace.len()-1] * *trace[trace.len()-1] + *trace[trace.len()-2] * *trace[trace.len()-2] ;

        trace.append(next_fib);
        
        i = i+1;
    };
    
    println!("fibonacci trace: {:?}", trace);

    let domain = CircleDomainImpl::new_with_log_size(log_size);

    let trace_column = CircleEvaluationImpl::new(domain, trace); //Duda: porque el circle evaluation toma tiras de QM31???

    array![trace_column]
}

struct WideFibonacciEval  { //
    pub log_n_rows: u32,
    pub number_of_instances: u32
}

#[generate_trait]
pub impl WideFibonacciEvalImpl of WideFibonacciEvalTrait{

}



#[cfg(test)]
mod tests {
    use stwo_cairo_verifier::pcs::verifier::CommitmentSchemeVerifierTrait;
use stwo_cairo_verifier::channel::ChannelTrait;
use super::StarkProof;
    use stwo_cairo_verifier::pcs::verifier::{VerificationError, PcsConfig, CommitmentSchemeProof, CommitmentSchemeVerifier, CommitmentSchemeVerifierImpl};
    use stwo_cairo_verifier::fri::verifier::{ FriProof, FriConfig, FriLayerProof};
    use stwo_cairo_verifier::channel::{ChannelTime, Channel};
    use stwo_cairo_verifier::vcs::verifier::MerkleDecommitment;
    use stwo_cairo_verifier::fields::qm31::{QM31, qm31};
    use stwo_cairo_verifier::fields::m31::m31;
    use stwo_cairo_verifier::poly::line::LinePoly;
    use stwo_cairo_verifier::poly::circle::{CircleDomainImpl, CircleEvaluation, CircleEvaluationImpl};
    use stwo_cairo_verifier::circle::{CirclePoint, CirclePointTrait, CirclePointQM31Impl};
    use stwo_cairo_verifier::fri::verifier::FriVerificationError;
    use stwo_cairo_verifier::utils::pow;


    fn verify(mut channel: Channel,
              mut commitment_scheme: CommitmentSchemeVerifier,
              proof: StarkProof)
              -> Result<(), VerificationError>{

                //components = ?????

                let random_coeff = channel.draw_felt();

                // Read composition polynomial commitment.
                let last_proof_commitment = proof.commitments.at(proof.commitments.len()-1);
                channel = commitment_scheme.commit(*last_proof_commitment, array![], channel);

                    // Draw OODS point.
                let oods_point: CirclePoint<QM31> = CirclePointTrait::get_random_point(channel);

                //mask from components??? lo hacemo a mano
                let mut sample_points = array![];
                sample_points.append(array![array![oods_point], array![oods_point], array![oods_point], array![oods_point]]);

                let sampled_oods_values = proof.commitment_scheme_proof.sampled_values;

                // Extract composition_eval???????
                let composition_oods_eval = qm31(0,0,0,0);

                commitment_scheme.verify_values(sample_points, proof.commitment_scheme_proof, ref channel)

                // Duda: en commitment_scheme.commit la funcion toma el channel, lo consume y devuelve otro channel,
                // pero en commitment_scheme.verify_values toma un ref a un channel y supongo que lo muta. Habria que estandarizar?
              }
    

    #[test]
    fn test_wide_fib_prove_with_poseidon() {
        // const LOG_N_INSTANCES: u32 = 6;
    


        let config: PcsConfig = PcsConfig {
            pow_bits: 5,
            fri_config: FriConfig{
                log_blowup_factor: 1,
                log_last_layer_degree_bound: 0,
                n_queries: 3
            }
        };


        // Verify.
        let verifier_channel = Channel {
            digest: 0x00, // Default
            channel_time: ChannelTime { n_challenges: 0, // Default
             n_sent: 0 // Default
             }
        };

        let proof = StarkProof{ 
            commitments: array![],
            commitment_scheme_proof: CommitmentSchemeProof {
                sampled_values: array![
                    array![array![qm31(2082657879, 1175528048, 1000432343, 763013627)]]
                ],
                decommitments: array![
                    MerkleDecommitment {
                        hash_witness: array![
                            0x008616ef876c5a76edb3abf09fd8ffd5d80ccadce1ad581844bbaa7235a2da56,
                            0x04d8220ddc27d89ae6846d9191ecf02c1c0bbcb25a6f7ac4685a9bf42f1f010f,
                            0x073f38df4fcaa0170ee42e66ead2de1824dedfa6413be32cc365595d116cc32b
                        ],
                        column_witness: array![]
                    }
                ],
                queried_values: array![array![array![m31(1323727772), m31(1323695004)].span()]],
                proof_of_work: 2,
                fri_proof: FriProof {
                    inner_layers: array![
                        FriLayerProof {
                            evals_subset: array![qm31(1095793631, 1536834955, 2042516263, 1366783014)],
                            decommitment: MerkleDecommitment {
                                hash_witness: array![
                                    0x0574b67cc46ad2d8f1f45ba903b57f7374e0358585e1129276cb0ad055c5ab9e,
                                    0x06156efae86345fb4e6c116dcdd41a00c430c91b3304163ba150ad51965f952d
                                ],
                                column_witness: array![]
                            },
                            commitment: 0x0627d9d20f6b14fbd148a257e77e56017fa4984332ceb30d87d71f79564a5541
                        },
                        FriLayerProof {
                            evals_subset: array![qm31(872305103, 1427717794, 368086230, 1461103938)],
                            decommitment: MerkleDecommitment {
                                hash_witness: array![
                                    0x0469214fcf5d28d3d24123d4f04b03309dca680896fb50e64cfdabd225050d3b
                                ],
                                column_witness: array![]
                            },
                            commitment: 0x0013431268a11ebb22826f67d87d1625f1064799577cc4709373d93ef05e1971
                        }
                    ],
                    last_layer_poly: LinePoly {
                        coeffs: array![qm31(42760190, 1889301382, 1748376489, 1325373839)], log_size: 0
                    }
                }
            }
        };
        

        let mut commitment_scheme = CommitmentSchemeVerifierImpl::new(config);

        let sizes: Array<Array<u32>> = array![]; //component.trace_log_degree_bounds();

        commitment_scheme.commit(*proof.commitments[0], sizes[0].clone(), verifier_channel);

        verify(verifier_channel, commitment_scheme, proof);

    }
}