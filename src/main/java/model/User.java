package model;

public class User {
    int id;    
    String name;
    String firstName;

    /**
     * Setters et Getters
     */
    public int getId(){
        return this.id;
    }

    public String getName(){
        return this.name;
    }
    
    public String getFirstName(){
        return this.name;
    }

    public void  setId(int Id){
        this.id = Id;
    }

    public void setName(String Name){
        this.name = Name;
    }

    public void setFirstName(String Name){
        this.name = Name;
    }

    /**
     * Constructeur
     */
    public User(String name, String firstName){
        setName(name);
        setFirstName(firstName);
    }
    public User (){}
}
