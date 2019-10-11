import com.google.gson.Gson;
import org.eclipse.jetty.websocket.api.RemoteEndpoint;
import org.eclipse.jetty.websocket.api.Session;
import org.eclipse.jetty.websocket.api.WebSocketAdapter;

import java.util.ArrayList;

public class AdapterWorldSocket extends WebSocketAdapter {
    private World world = World.initialize();
    private Gson gson = new Gson();
    @Override
    public void onWebSocketConnect(Session session) {
        super.onWebSocketConnect(session);
        world.addUser(session);
        System.out.println("Added user: " + session.toString());
        if (isConnected()) {
            User currentUser = world.getUser(getSession());
            System.out.println("Added user: " + currentUser.getId());

        }

    }

    @Override
    public void onWebSocketText(String message) {

        if (isConnected()) {
            System.out.println(message);
            User currentUser = world.getUser(getSession());
            RemoteEndpoint currentEndpoint = currentUser.getSession().getRemote();
            if(message.startsWith("state")){
                currentUser.createState();
                currentUser.getSession().getRemote().
                        sendStringByFuture(gson.toJson(currentUser.getState()));
            }
            if (message.startsWith("position")) {
                //msg processing
                String[] splitted = message.split(":");
                String level = splitted[1];
                String field = splitted[2];
                writeMovementString(getSession(), "position",level, field);
             }
            if (message.startsWith("payoff")) {
                //msg processing
                String[] splitted = message.split(":");
                String level = splitted[1];
                String field = splitted[2];

                writeMovementString(getSession(), "payoff",level, field);
            }
            if (message.startsWith("mask")) {
                //msg processing
                String[] splitted = message.split(":");
                String level = splitted[1];
                String field = splitted[2];

                writeMovementString(getSession(), "mask",level, field);
            }
            if (message.startsWith("endPosition")) {
                World.getLogger().flushMovementFile();
                String[] splitted = message.split(":");
                String level = splitted[1];
                String position = splitted[2];
                currentUser.getState().getLandscapes().get(Integer.parseInt(level)).receivedFromParticipant();
                String[] newPositionString = position.split(",");
                ArrayList<Integer> newPosition = new ArrayList<>();
                for(String s : newPositionString){
                    newPosition.add(Integer.parseInt(s));
                }
                currentUser.getState().getLandscapes().get(Integer.parseInt(level)).setSequentialPosition(newPosition);
            }

            if (message.startsWith("participant")) {
                String[] splitted = message.split(":");
                writeParticipantString(getSession(), splitted[1]);
                world.getLogger().flushParticipantFile();
            }
            if (message.startsWith("remove")) {
                for (User u : world.getAllUsers()) {
                    u.getSession().close();
                    world.removeUser(u.getSession());
                }
                world.getLogger().restartFiles(world.getPathPrefix());
            }
            if (message.startsWith("endExperiment")) {
                world.getLogger().flushMovementFile();
                currentUser.setFinished(true);
            }
        }
    }

    private void writeMovementString(Session session, String type, String level, String message) {
        User currentUser = world.getUser(session);

        world.getLogger().writeToMovementFile(world.getTime() + "," + currentUser.getId() +
                "," + level + "," +type +"," + message + "\n");
    }

    private void writeParticipantString(Session session, String text) {
        User currentUser = world.getUser(session);


        world.getLogger().writeToParticipantFile(world.getTime() + ","
                + currentUser.getId() + "," + text + "\n");

    }

    @Override
    public void onWebSocketClose(int statusCode, String reason) {
        world.getLogger().flushMovementFile();
        world.removeUser(getSession());

    }
}