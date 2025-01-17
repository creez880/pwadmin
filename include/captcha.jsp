<%@ page import="java.awt.Color, java.awt.Font, java.awt.Graphics, java.awt.image.BufferedImage, javax.imageio.ImageIO" %>
<%
    response.setContentType("image/png"); // Set MIME type
    response.setHeader("Cache-Control", "no-cache"); // Nonaktifkan caching

    // Ukuran gambar untuk 4 huruf
    int width = 100, height = 50;
    BufferedImage bufferedImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
    Graphics g = bufferedImage.getGraphics();

    // Background
    g.setColor(Color.LIGHT_GRAY);
    g.fillRect(0, 0, width, height);

    // Generate 4 random characters
    String chars = "ABCDEFGHJKLMNOPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz0123456789";
    StringBuilder captchaText = new StringBuilder();
    for (int i = 0; i < 4; i++) {
        captchaText.append(chars.charAt((int) (Math.random() * chars.length())));
    }

    // Store captcha in session
    session.setAttribute("captcha", captchaText.toString());

    // Draw each character in a random position
    g.setFont(new Font("Arial", Font.BOLD, 24));
    for (int i = 0; i < 4; i++) {
        int x = 15 + (i * 20) + (int) (Math.random() * 5); // Randomize x position slightly
        int y = 25 + (int) (Math.random() * 10);          // Randomize y position
        g.setColor(new Color(
            (int) (Math.random() * 256), // Random Red
            (int) (Math.random() * 256), // Random Green
            (int) (Math.random() * 256)  // Random Blue
        ));
        g.drawString(String.valueOf(captchaText.charAt(i)), x, y);
    }

    // Add random noise lines with random colors
    for (int i = 0; i < 10; i++) {
        int x1 = (int) (Math.random() * width);
        int y1 = (int) (Math.random() * height);
        int x2 = (int) (Math.random() * width);
        int y2 = (int) (Math.random() * height);

        g.setColor(new Color(
            (int) (Math.random() * 256), // Random Red
            (int) (Math.random() * 256), // Random Green
            (int) (Math.random() * 256)  // Random Blue
        ));
        g.drawLine(x1, y1, x2, y2);
    }

    g.dispose();

    // Write image to output stream
    try {
        ImageIO.write(bufferedImage, "png", response.getOutputStream());
        response.getOutputStream().flush(); // Ensure the image is fully written
        response.getOutputStream().close(); // Close the output stream
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
