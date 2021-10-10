class HybridCross
  
    # Attribute accessors:
    attr_accessor :parent1, :parent2, :f2_wild, :f2_p1, :f2_p2, :f2_p1p2, :linked
    attr_reader :estimator, :cutoff_probability
  
    def initialize(params = {})
        @parent1 = params.fetch(:parent1, "Parent 1 ID") # stock id
        @parent2 = params.fetch(:parent2, "Parent 2 ID") # stock id
        @f2_wild = params.fetch(:f2_wild, 0).to_i # converting the string to integer
        @f2_p1 = params.fetch(:f2_p1, 0).to_i # converting the string to integer
        @f2_p2 = params.fetch(:f2_p2, 0).to_i # converting the string to integer
        @f2_p1p2 = params.fetch(:f2_p1p2, 0).to_i # converting the string to integer
        @linked = nil #default. after analysing: true if linked, false if not
        @estimator = nil #default
        @cutoff_probability = nil #default
        # estimator and cutoff_probability will store those results after a chi_square_test has been performed
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
        
        @estimator = estimator # storing the estimator
        
        # Hash with:
        # Values: Probabilities that the genes are not linked
        # Keys: The value of the chi square estimator for each probability
        probs = [0.1, 0.05, 0.01]
        estimators = [6.25, 7.82, 11.34]
        probs_values = probs.zip(estimators).to_h # zipping both arrays and converting it to hash
        
        unless probs_values.has_key?(cutoff_probability) # If the probability isn't in our hash
            puts "WARNING: the probability cutoff provided isn't in our array, we will use the default 0.05"
            cutoff_probability = 0.05
        end
        
        @cutoff_probability = cutoff_probability # storing the cutoff used
        
        # Checking if our estimator is >= the estimator corresponding to the cutoff probability
        if estimator >= probs_values[cutoff_probability]
            @linked = true
        else
            @linked = false
        end
    end
end