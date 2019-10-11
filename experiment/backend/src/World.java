import org.eclipse.jetty.websocket.api.Session;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

/**
 * Created by Yahosseini on 15.12.2016.
 */
public final class World {
    public int NUMBEROFLEVEL;
    private String pathPrefix = "./";
    private static World instance = null;
    private ArrayList<Landscape> landscapes = new ArrayList<>();
    private Set<User> users = new CopyOnWriteArraySet<>();
    private static Logger logger;
    private int userIdNumber = 0;
    private int landscapesPerCategory;

    private World() {

        NUMBEROFLEVEL = 200;
        System.out.println(NUMBEROFLEVEL);
        for (int i = 0; i < NUMBEROFLEVEL; i++) {
            Landscape landscape = new Landscape(i, false, false);
            landscapes.add(landscape);
            landscape = new Landscape(i, false, true);
            landscapes.add(landscape);
            landscape = new Landscape(i, true, false);
            landscapes.add(landscape);
            landscape = new Landscape(i, true, true);
            landscapes.add(landscape);
        }
        Collections.shuffle(landscapes);
    }

    public static World initialize() {
        if (instance == null) {

            instance = new World();
            logger = new Logger();
        }
        return instance;
    }

    public static World getWorld() {
        return instance;
    }

    public String getPathPrefix() {
        return pathPrefix;
    }

    public ArrayList<Landscape> getUsableLandscapes() {
        ArrayList<Landscape> eligibleLandscapes = new ArrayList<>();
        eligibleLandscapes.addAll(getUsableSpecialLandscapes(16, false, false, false));
        eligibleLandscapes.addAll(getUsableSpecialLandscapes(16, false, false, true));
        eligibleLandscapes.addAll(getUsableSpecialLandscapes(16, false, true, false));
        eligibleLandscapes.addAll(getUsableSpecialLandscapes(16, false, true, true));
        eligibleLandscapes.addAll(getUsableSpecialLandscapes(16, true, false, false));
        eligibleLandscapes.addAll(getUsableSpecialLandscapes(16, true, false, true));
        eligibleLandscapes.addAll(getUsableSpecialLandscapes(16, true, true, false));
        eligibleLandscapes.addAll(getUsableSpecialLandscapes(16, true, true, true));
        return (eligibleLandscapes);
    }

    private ArrayList<Landscape> getUsableSpecialLandscapes(int number, boolean isSequential,
                                                            boolean isSmooth, boolean isLowStrength) {
        ArrayList<Landscape> eligibleLandscapes = new ArrayList<>();

            for (Landscape landscape : this.landscapes) {
                if(eligibleLandscapes.size() >= number){
                    break;
                }
                if (landscape.canBeSendToParticipant() &
                        (landscape.isSequential() == isSequential) &
                        (landscape.isSmooth() == isSmooth) &
                        (landscape.isLowStrength() == isLowStrength)) {
                    eligibleLandscapes.add(landscape);
                    landscape.sendToParticipant();

            }
        }
        return (eligibleLandscapes);
    }

    public void addUser(Session session) {
        User user = new User(session, userIdNumber);
        users.add(user);
        userIdNumber++;


    }

    public void removeUser(Session session) {

        for (User user : users) {
            if (user.getSession().equals(session)) {
                users.remove(user);
                if(!user.isFinished()){
                    for(Landscape landscape : user.getState().getLandscapes()){
                        landscape.receivedUnfinishedFromParticipant();
                    }
                    System.out.println("[WARNING] DROPOUT: " + user.getId());
                }

                System.out.println("Removed user: " + user.getId());
            }
        }

    }

    public User getUser(Session session) {
        for (User user : users) {
            if (user.getSession().equals(session)) {
                return user;
            }
        }
        return null;
    }

    public Set<User> getAllUsers() {
        return users;
    }

    public static Logger getLogger() {
        return logger;
    }

    public String getTime() {
        return Instant.now().toString();
    }

}
