import java.util.ArrayList;
import java.util.Collections;

/**
 * Created by Yahosseini on 15.12.2016.
 */
public class Landscape {
    private String id = "Landscape";
    private Integer landscapeId;

    private ArrayList<Integer> starting;
    private ArrayList<Integer> sequentialPosition;
    private Boolean isSmooth;
    private Integer participantsPending;
    private Integer sendOutToParticipants;
    private Boolean isSequential;
    private Boolean isLowStrength;


    Landscape(int landscapeId, boolean isSequential, boolean isLowStrength){
        this.landscapeId = landscapeId;
        this.isSequential = isSequential;
        this.isLowStrength = isLowStrength;

        this.starting = new ArrayList<>();
        for(int i = 0;i<10;i++){
            starting.add((int)Math.round(Math.random()));
        }
        Collections.shuffle(starting);
        this.isSmooth = ((this.landscapeId%2) == 0);

        this.sequentialPosition = this.starting;
        this.participantsPending = 0;
        this.sendOutToParticipants = 0;
    }


    public ArrayList<Integer> getStarting() {
        return starting;
    }

    public ArrayList<Integer> getSequentialPosition() {
        return sequentialPosition;
    }


    public void setSequentialPosition(ArrayList<Integer> sequentialPosition) {
        this.sequentialPosition = sequentialPosition;
    }

    public void sendToParticipant() {
        this.participantsPending++;
        this.sendOutToParticipants++;
    }

    public void receivedFromParticipant() {
        this.participantsPending--;
    }
    public void receivedUnfinishedFromParticipant(){

        this.participantsPending--;
        this.sendOutToParticipants--;
    }

    public boolean canBeSendToParticipant() {
        return((participantsPending == 0) &(sendOutToParticipants < 8) );
    }

    public boolean isSequential() {
        return isSequential;
    }

    public boolean isLowStrength() {
        return isLowStrength;
    }

    public int getLandscapeId() {
        return landscapeId;
    }

    public boolean isSmooth() {
        return isSmooth;
    }

    public String toCsvString(){
        return(landscapeId.toString() + ","
                + isSmooth.toString() + ","
                + isSequential.toString() + ","
                + isLowStrength.toString()+ ","
                + sendOutToParticipants.toString());

    }
}



