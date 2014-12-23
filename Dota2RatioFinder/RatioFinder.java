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
    private boolean hasDrawn = false;
    private double ratioX, ratioY, ratioW, ratioH;
    private double finalX = 0, finalY = 0, finalW = 0, finalH = 0;
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
        canvas.setCursor(Cursor.CROSSHAIR);


        Scene scene = new Scene(border);
        primaryStage.setScene(scene);
        //primaryStage.setResizable(false);
        primaryStage.sizeToScene();
        primaryStage.show();

        canvas.addEventHandler(MouseEvent.MOUSE_PRESSED, (MouseEvent e) -> {
            onPressed(e);
        });

        canvas.addEventHandler(MouseEvent.MOUSE_DRAGGED, (MouseEvent e) -> {
            onDragged(e);
        });

        canvas.addEventHandler(MouseEvent.MOUSE_RELEASED, (MouseEvent e) -> {
            onReleased(e);
        });

    }

    public void onPressed(MouseEvent e) {
        if (hasDrawn) {
            g.clearRect(0, 0, sampleScreen.getWidth(), sampleScreen.getHeight());
        }

        double ratioX = e.getX() / sampleScreen.getWidth();
        double ratioY = e.getY() / sampleScreen.getHeight();
        textFieldX.setText(Double.toString(ratioX));
        textFieldY.setText(Double.toString(ratioY));
        textFieldW.setText("0");
        textFieldH.setText("0");
        oldX = e.getX();
        oldY = e.getY();
    }

    public void onDragged(MouseEvent e) {

        if (hasDrawn) {
            g.clearRect(0, 0, sampleScreen.getWidth(), sampleScreen.getHeight());
        }

        g.setFill(Color.TRANSPARENT);
        g.setStroke(Color.WHITE);
        g.fillRect(0, 0, sampleScreen.getWidth(), sampleScreen.getHeight());

        if ((e.getX() - oldX) > 0 && (e.getY() - oldY) > 0) {
            if (e.isShiftDown()) {
                double a = e.getX() - oldX;
                double b = e.getY() - oldY;
                double minVal = (a < b) ? a : b;
                finalX = oldX;
                finalY = oldY;
                finalW = minVal;
                finalH = minVal;
            } else {
                finalX = oldX;
                finalY = oldY;
                finalW = e.getX() - oldX;
                finalH = e.getY() - oldY;
            }
        } else if ((e.getX() - oldX) < 0 && (e.getY() - oldY) < 0) {

            if (e.isShiftDown()) {
                double a = oldX - e.getX();
                double b = oldY - e.getY();
                double minVal = (a < b) ? a : b;
                finalX = oldX - minVal;
                finalY = oldY - minVal;
                finalW = minVal;
                finalH = minVal;
            } else {
                finalX = e.getX();
                finalY = e.getY();
                finalW = oldX - e.getX();
                finalH = oldY - e.getY();
            }

        //Working
        } else if ((e.getX() - oldX) < 0 && (e.getY() - oldY) > 0) {
            if (e.isShiftDown()) {
                double a = oldX - e.getX();
                double b = e.getY() - oldY;
                double minVal = (a < b) ? a : b;
                finalX = oldX - minVal;
                finalY = oldY;
                finalW = minVal;
                finalH = minVal;
            } else {
                finalX = e.getX();
                finalY = oldY;
                finalW = oldX - e.getX();
                finalH = e.getY() - oldY;
            }

        } else if ((e.getX() - oldX) > 0 && (e.getY() - oldY) < 0) {
            if (e.isShiftDown()) {
                double a = e.getX() - oldX;
                double b = oldY - e.getY();
                double minVal = (a < b) ? a : b;
                finalX = oldX;
                finalY = oldY - minVal;
                finalW = minVal;
                finalH = minVal;
            } else {
                finalX = oldX;
                finalY = e.getY();
                finalW = e.getX() - oldX;
                finalH = oldY - e.getY();
            }
        }

        if (finalX < 0) {
            finalX = 0;
        }
        if ((finalX + finalW) > sampleScreen.getWidth()) {
            finalW = sampleScreen.getWidth() - finalX;
        }

        if (finalY < 0) {
            finalY = 0;
        }
        if ((finalY + finalH) > sampleScreen.getHeight()) {
            finalH = sampleScreen.getHeight() - finalY;
        }

            ratioX = finalX / sampleScreen.getWidth();
            ratioY = finalY / sampleScreen.getHeight();
            ratioW = finalW / sampleScreen.getWidth();
            ratioH = finalH / sampleScreen.getHeight();
            textFieldX.setText(Double.toString(ratioX));
            textFieldY.setText(Double.toString(ratioY));
            textFieldW.setText(Double.toString(ratioW));
            textFieldH.setText(Double.toString(ratioH));
            g.strokeRect(finalX, finalY, finalW, finalH);

        hasDrawn = true;
    }

    public void onReleased(MouseEvent e) {

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
