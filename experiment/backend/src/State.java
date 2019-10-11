import java.util.ArrayList;
import java.util.Collections;

/**
 * Created by Yahosseini on 06.01.2017.
 */
public class State {


    private ArrayList<Landscape> landscapes = new ArrayList<>();
    private String id = "State";

    public State() {
        World world = World.getWorld();
        this.landscapes.addAll(world.getUsableLandscapes());
        Collections.shuffle(landscapes);
    }

    public ArrayList<Landscape> getLandscapes() {
        return landscapes;
    }
}

