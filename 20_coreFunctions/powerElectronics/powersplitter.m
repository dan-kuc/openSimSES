A=exist('inverterSwitch');
pOut_Individual=zeros(inverterNumber,1);
switch strat_pe
    case 'uniform'
        pInRef_Individual=pInRef/inverterNumber;
        sign(pInRef);
    case 'cascaded non-uniform'
        flag=0;
        pInRef_Individual=zeros(inverterNumber,1);
        if (inverterSwitch>0.8 && abs(pInRef)>inverterSwitch*pInverterNom && abs(pInRef)<pInverterNom)
            inverterSwitch=1;
        end
        if abs(pInRef)>pInverterNom
            pInRef_Individual(:)=pInverterNom_Individual;
        elseif abs(pInRef)<inverterSwitch*pInverterNom
            if (abs(pInRef)<pInverterNom_Individual*inverterSwitch)
                    pInRef_Individual(1)=pInRef;
                    flag=1;
    %                 pInRef_Individual=pInRef_Individual+pInverterNom_Individual*StandbyLosses*sign(pInRef);
            end

            if (abs(pInRef)>pInverterNom_Individual*inverterSwitch && abs(pInRef)<2*pInverterNom_Individual*inverterSwitch )
                    pInRef_Individual(1)=pInverterNom_Individual*inverterSwitch*sign(pInRef);
                    pInRef_Individual(2)=pInRef-sum(pInRef_Individual);
                    flag=1;
            end
    %         pInRef_Individual=pInRef_Individual+pInverterNom_Individual*StandbyLosses*sign(pInRef);


            if (flag==0)
                i=1;
                while (abs(pInRef)>=i*pInverterNom_Individual*inverterSwitch && i<=inverterNumber)
                    pInRef_Individual(1:i)=pInverterNom_Individual*inverterSwitch*sign(pInRef);
                    pInRef_Individual(i+1)=pInRef-sum(pInRef_Individual); %TODO - This causes an extra entry in the distribution if there is still some leftover power
                    i=i+1;

                end
%             pInRef_Individual=pInRef_Individual+pInverterNom_Individual*StandbyLosses*sign(pInRef);
            end
                
        
        end
        
        
        
            

end
        