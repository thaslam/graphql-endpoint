import { AppSyncResolverHandler } from "aws-lambda";
import type { Joke } from '../../model/types';

/* TODO: this concreate class should move to another file */
class LocalJoke implements Joke {

    id: string;
    frame: string;
    punchline: string;
    type: string;

    // do nothing for now
    constructor(id: string, frameText: string, punchlineText: string) {
        this.id = id;
        this.frame = frameText;
        this.punchline = punchlineText;
        this.type = "Simple";
    }
}

export const handler: AppSyncResolverHandler<void, Array<Joke>> = async (event) => {

    var jokes: Array<Joke> = [
        new LocalJoke("1", "Why did the chicken cross the road?", "To get to the other side."),
        new LocalJoke("2", "Did you hear about the mathematician who’s afraid of negative numbers?", "He’ll stop at nothing to avoid them."),
        new LocalJoke("3", "Why don’t scientists trust atoms?", "Because they make up everything.")
    ];

    return jokes;
};