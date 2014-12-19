import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.StackPane;
import javafx.stage.Stage;
import javafx.scene.Cursor;
import javafx.scene.layout.HBox;
import javafx.scene.control.Label;
import javafx.geometry.Pos;
import javafx.scene.layout.BorderPane;
import javafx.geometry.Insets;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.scene.text.Text;
import javafx.scene.control.TextField;
import javafx.scene.paint.Color;
import javafx.scene.canvas.GraphicsContext;
import javafx.scene.canvas.Canvas;

/**
* Load image from source. This class starts up the JavaFX application.
*
* @author Zanko
* @version 1.0
*/
public class RatioFinder extends Application {
    private Image sampleScreen;
    private HBox hbox;
    private int x = 0;
    private TextField textFieldX;
    private TextField textFieldY;
    private TextField textFieldH;
    private TextField textFieldW;
    private double oldX;
    private double oldY;
    private GraphicsContext g;
    private Canvas canvas;
    private double oldRectX;
    private double oldRectY;
    private double oldRectW;
    private double oldRectH;
    private boolean hasDrawn = false;

    public static void main(String[] args) {
        Application.launch(args);
    }

    @Override
    public void start(Stage primaryStage) {
        primaryStage.setTitle("Dota2 Ratio Finder");
        StackPane stackPane = new StackPane();
        sampleScreen = new Image("SampleScreen.jpg");

        canvas = new Canvas(sampleScreen.getWidth(), sampleScreen.getHeight());
        g = canvas.getGraphicsContext2D();
        g.setFill(Color.TRANSPARENT);
        g.fillRect(0, 0, sampleScreen.getWidth(), sampleScreen.getHeight());

        ImageView imageView = new ImageView(sampleScreen);
        BorderPane border = new BorderPane();

        border.setBottom(addHBox());
        stackPane.getChildren().add(imageView);
        stackPane.getChildren().add(canvas);

        border.setCenter(stackPane);
        imageView.setCursor(Cursor.CROSSHAIR);


        Scene scene = new Scene(border);
        primaryStage.setScene(scene);
        primaryStage.setResizable(false);
        primaryStage.sizeToScene();
        primaryStage.show();

        canvas.addEventHandler(MouseEvent.MOUSE_PRESSED, (MouseEvent e) -> {
            onPressed(e);
        });

        canvas.addEventHandler(MouseEvent.MOUSE_RELEASED, (MouseEvent e) -> {
            onReleased(e);
        });
    }

    public void onPressed(MouseEvent e) {
        double ratioX = e.getX() / sampleScreen.getWidth();
        double ratioY = e.getY() / sampleScreen.getHeight();
        textFieldX.setText(Double.toString(ratioX));
        textFieldY.setText(Double.toString(ratioY));
        oldX = e.getX();
        oldY = e.getY();
    }


    public void onReleased(MouseEvent e) {
        g.setFill(Color.TRANSPARENT);
        g.setStroke(Color.WHITE);
        g.fillRect(0, 0, sampleScreen.getWidth(), sampleScreen.getHeight());
        if (hasDrawn) {
            g.clearRect(0, 0, sampleScreen.getWidth(), sampleScreen.getHeight());
        }
        if ((e.getX() - oldX) > 0 && (e.getY() - oldY) > 0) {
            g.strokeRect(oldX, oldY, e.getX() - oldX, e.getY() - oldY);
            double ratioX = oldX / sampleScreen.getWidth();
            double ratioY = oldY / sampleScreen.getHeight();
            double ratioW = (e.getX() - oldX) / sampleScreen.getWidth();
            double ratioH = (e.getX() - oldX) / sampleScreen.getHeight();
            textFieldX.setText(Double.toString(ratioX));
            textFieldY.setText(Double.toString(ratioY));
            textFieldW.setText(Double.toString(ratioW));
            textFieldH.setText(Double.toString(ratioH));
        } else if ((e.getX() - oldX) < 0 && (e.getY() - oldY) < 0) {
            g.strokeRect(e.getX(), e.getY(), oldX - e.getX() , oldY - e.getY());
            double ratioX = e.getX() / sampleScreen.getWidth();
            double ratioY = e.getY() / sampleScreen.getHeight();
            double ratioW = (oldX - e.getX()) / sampleScreen.getWidth();
            double ratioH = (oldY - e.getY()) / sampleScreen.getHeight();
            textFieldX.setText(Double.toString(ratioX));
            textFieldY.setText(Double.toString(ratioY));
            textFieldW.setText(Double.toString(ratioW));
            textFieldH.setText(Double.toString(ratioH));

        } else if ((e.getX() - oldX) < 0 && (e.getY() - oldY) > 0) {
            g.strokeRect(e.getX(), oldY, oldX - e.getX(), e.getY() - oldY);
            double ratioX = e.getX() / sampleScreen.getWidth();
            double ratioY = oldY / sampleScreen.getHeight();
            double ratioW = (oldX - e.getX()) / sampleScreen.getWidth();
            double ratioH = (e.getY() - oldY) / sampleScreen.getHeight();
            textFieldX.setText(Double.toString(ratioX));
            textFieldY.setText(Double.toString(ratioY));
            textFieldW.setText(Double.toString(ratioW));
            textFieldH.setText(Double.toString(ratioH));

        } else if ((e.getX() - oldX) > 0 && (e.getY() - oldY) < 0) {
            g.strokeRect(oldX, e.getY(), e.getX() - oldX, oldY - e.getY());
            double ratioX = oldX / sampleScreen.getWidth();
            double ratioY = e.getY() / sampleScreen.getHeight();
            double ratioW = (e.getX() - oldX) / sampleScreen.getWidth();
            double ratioH = (oldY - e.getY()) / sampleScreen.getHeight();
            textFieldX.setText(Double.toString(ratioX));
            textFieldY.setText(Double.toString(ratioY));
            textFieldW.setText(Double.toString(ratioW));
            textFieldH.setText(Double.toString(ratioH));
        }
        hasDrawn = true;
    }

    private HBox addHBox() {
        hbox = new HBox();
        hbox.setStyle("-fx-background-color: #FFFFFF;");
        hbox.setPadding(new Insets(20));
        hbox.setSpacing(15);

        Text title = new Text("Coordinates Ratio");
        Label labelX = new Label("X Ratio");
        Label labelY = new Label("Y Ratio");
        Label labelW = new Label("W Ratio");
        Label labelH = new Label("H Ratio");
        textFieldX = new TextField("0");
        textFieldY = new TextField("0");
        textFieldW = new TextField("0");
        textFieldH = new TextField("0");
        textFieldX.setEditable(false);
        title.setFill(Color.BLACK);
        title.setFont(Font.font("Arial", FontWeight.BOLD, 15));

        hbox.getChildren().add(title);
        hbox.getChildren().add(labelX);
        hbox.getChildren().add(textFieldX);
        hbox.getChildren().add(labelY);
        hbox.getChildren().add(textFieldY);
        hbox.getChildren().add(labelW);
        hbox.getChildren().add(textFieldW);
        hbox.getChildren().add(labelH);
        hbox.getChildren().add(textFieldH);
        hbox.setAlignment(Pos.CENTER);
        return hbox;
    }
}
