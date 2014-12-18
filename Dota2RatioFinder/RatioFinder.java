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

    public static void main(String[] args) {
        Application.launch(args);
    }

    @Override
    public void start(Stage primaryStage) {
        primaryStage.setTitle("Dota2 Ratio Finder");
        StackPane stackPane = new StackPane();
        sampleScreen = new Image("SampleScreen.jpg");
        ImageView imageView = new ImageView(sampleScreen);
        BorderPane border = new BorderPane();

        border.setBottom(addHBox());
        stackPane.getChildren().add(imageView);
        border.setCenter(stackPane);
        imageView.setCursor(Cursor.CROSSHAIR);

        Scene scene = new Scene(border);
        primaryStage.setScene(scene);
        primaryStage.setResizable(false);
        primaryStage.sizeToScene();
        primaryStage.show();

        imageView.addEventHandler(MouseEvent.MOUSE_PRESSED, (MouseEvent e) -> {
                onPress(e);
            });
    }

    public void onPress(MouseEvent e) {
        double ratioX =  e.getX() / sampleScreen.getWidth();
        double ratioY =  e.getY() / sampleScreen.getHeight();
        textFieldX.setText(Double.toString(ratioX));
        textFieldY.setText(Double.toString(ratioY));
    }

    private HBox addHBox() {
        hbox = new HBox();
        hbox.setStyle("-fx-background-color: #FFFFFF;");
        hbox.setPadding(new Insets(20));
        hbox.setSpacing(15);

        Text title = new Text("Coordinates Ratio");
        Label labelX = new Label("X Ratio");
        Label labelY = new Label("Y Ratio");
        textFieldX = new TextField("0");
        textFieldY = new TextField("0");
        textFieldX.setEditable(false);
        title.setFill(Color.BLACK);
        title.setFont(Font.font("Arial", FontWeight.BOLD, 15));

        hbox.getChildren().add(title);
        hbox.getChildren().add(labelX);
        hbox.getChildren().add(textFieldX);
        hbox.getChildren().add(labelY);
        hbox.getChildren().add(textFieldY);
        hbox.setAlignment(Pos.CENTER);
        return hbox;
    }
}
