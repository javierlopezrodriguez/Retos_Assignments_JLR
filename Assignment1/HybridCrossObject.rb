class HybridCross
  
    def initialize(params = {})
        @parent1 = params.fetch(:Parent1, "Parent 1 ID")
        @parent2 = params.fetch(:Parent2, "Parent 2 ID")
        @f2_wild = params.fetch(:F2_Wild, 0).to_i # converting the string to integer
        @f2_p1 = params.fetch(:F2_P1, 0).to_i # converting the string to integer
        @f2_p2 = params.fetch(:F2_P2, 0).to_i # converting the string to integer
        @f2_p1p2 = params.fetch(:F2_P1P2, 0).to_i # converting the string to integer
    end
    #code
    
    def chi_square_test(cutoff_probability = 0.05)
      
        # Computes the chi square test for a hybrid cross,
        # following the instructions in: https://www2.palomar.edu/users/warmstrong/lmexer4.htm#introduction
        
        # Total observed phenotypes
        total = @f2_wild + @f2_p1 + @f2_p2 + @f2_p1p2
        
        # Creating an array containing the observed and expected number of each phenotype
        observed = [@f2_wild, @f2_p1, @f2_p2, @f2_p1p2]
        expected = [total * 9/16, total * 3/16, total * 3/16, total * 1/16]
        obs_exp_pairs = observed.zip(expected) # arranges it as [observed wild, expected wild], [observed p1, expected p1]...
        
        # Chi square estimator:
        estimator = 0 # start value
        obs_exp_pairs.each do |obs, exp| # for each [observed, expected] pair
            estimator += ((obs - exp)**2/exp).round(3) # add that expression to the current value of estimator
        end
        
        # Hash with:
        # Values: Probabilities that the genes are not linked
        # Keys: The value of the chi square estimator for each probability
        probs = [0.9, 0.7, 0.6, 0.5, 0.2, 0.1, 0.05, 0.01]
        estimators = [0.58, 1.42, 1.85, 2.37, 4.64, 6.25, 7.82, 11.34]
        probs_values = probs.zip(estimators).to_h # zipping both arrays and converting it to hash
        
        # If the probability isn't in 
        unless probs_values.has_key?(cutoff_probability)
        cutoff = 0.05 
        
        
        
        
        
    end


end