import org.eclipse.jetty.websocket.api.Session;

/**
 * Created by Yahosseini on 19.12.2016.
 */
public class User {
    private int userId;
    private Session session;

    private State state;
    private boolean finished;

    public State getState() {
        return this.state;
    }

    public User(Session session, int id) {
        userId = id;
        this.session = session;
        finished = false;


    }
    public int getId() {
        return userId;
    }
    public void createState() {
        this.state = new State();
        int i = 0;
        for (Landscape l : this.state.getLandscapes()) {
            World.getLogger().writeToStructureFile(userId + "," + i + "," + l.toCsvString() + "\n");
            i++;
        }
        World.getLogger().flushStructureFile();}
    public Session getSession() {
        return session;
    }

    public boolean isFinished() {
        return finished;
    }

    public void setFinished(boolean finished) {
        this.finished = finished;
    }
}
