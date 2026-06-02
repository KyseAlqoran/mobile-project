package com.example.dropp_mobile_app;

public class Products {
    private String name;
    private String description;
    private String price;
    private int imgID;

    public static final Products[] products = {
            new Products("Street Flow Tee", "Oversized clean drip", "$39 USD", R.drawable.img),
            new Products("FlexMode Hoodie", "Built for daily flex", "$69 USD", R.drawable.img_1),
            new Products("Urban Jacket", "Streetwear essential", "$89 USD", R.drawable.img_2),
            new Products("Cargo Pants", "Relaxed utility fit", "$59 USD", R.drawable.img_3),
    };

    public Products(String name, String description, String price, int imgID) {
        this.name = name;
        this.description = description;
        this.price = price;
        this.imgID = imgID;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public String getPrice() {
        return price;
    }

    public int getImgID() {
        return imgID;
    }
}